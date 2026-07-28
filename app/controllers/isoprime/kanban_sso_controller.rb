# frozen_string_literal: true

module Isoprime
  class KanbanSsoController < ApplicationController

    def show
      user_id = params[:user_id]

      return head :unauthorized unless user_id.present?

      user = User.find_by(id: user_id)

      return head :unauthorized unless user

      account_id = ENV.fetch('ISOPRIME_CHATWOOT_ACCOUNT_ID', '1').to_i

      account_user = user.account_users.find_by(account_id: account_id)

      return head :forbidden unless account_user

      payload = {
        id: user.id,
        name: user.name,
        email: user.email,
        role: account_user.role,
        account_id: account_id,
        iss: 'chatwoot-isoprime',
        iat: Time.current.to_i,
        exp: 60.seconds.from_now.to_i
      }

      token = gerar_token_sso(payload)

      kanban_url = ENV.fetch(
        'ISOPRIME_KANBAN_URL',
        'https://projeto-isoprime-kanban.iuw3ed.easypanel.host'
      )

      redirect_to(
        "#{kanban_url}/auth/chatwoot/sso?token=#{token}",
        allow_other_host: true
      )
    end

    def colunas

      user_id = params[:user_id]

      return head :unauthorized unless user_id.present?

      user = User.find_by(id: user_id)

      return head :unauthorized unless user


      account_id = ENV.fetch('ISOPRIME_CHATWOOT_ACCOUNT_ID', '1').to_i

      account_user = user.account_users.find_by(account_id: account_id)

      return head :forbidden unless account_user


      payload = {
        id: user.id,
        name: user.name,
        email: user.email,
        role: account_user.role,
        account_id: account_id,
        iss: 'chatwoot-isoprime',
        iat: Time.current.to_i,
        exp: 60.seconds.from_now.to_i
      }


      token = gerar_token_sso(payload)


      kanban_url = ENV.fetch(
        'ISOPRIME_KANBAN_URL'
      )


      response = Faraday.get(
        "#{kanban_url}/api/kanban/colunas",
        nil,
        {
          'Authorization' => "Bearer #{token}",
          'Accept' => 'application/json'
        }
      )


      render json: JSON.parse(response.body)

    rescue StandardError => e

      Rails.logger.error("KANBAN COLUNAS: #{e.message}")

      render json: {
        success:false,
        message:'Erro ao buscar etapas do funil'
      }, status:500

    end

    def alterar_etapa

      user_id = params[:user_id]

      return head :unauthorized unless user_id.present?

      user = User.find_by(id: user_id)

      return head :unauthorized unless user


      dados = JSON.parse(request.body.read)

      etapa_funil = dados['etapa_funil']


      return render json: {
        success:false,
        message:'Etapa não informada'
      }, status:422 unless etapa_funil.present?


      kanban_url = ENV.fetch(
        'ISOPRIME_KANBAN_URL'
      )


      token = gerar_token_sso({
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.account_users.find_by(account_id: 1)&.role,
        account_id: 1,
        iss:'chatwoot-isoprime',
        iat:Time.current.to_i,
        exp:60.seconds.from_now.to_i
      })


      response = Faraday.patch(
        "#{kanban_url}/api/kanban/conversas/#{params[:conversation_id]}/etapa",
        {
          etapa_funil: etapa_funil
        }.to_json,
        {
          'Authorization'=>"Bearer #{token}",
          'Content-Type'=>'application/json',
          'Accept'=>'application/json'
        }
      )


      begin

        render json: JSON.parse(response.body), status: response.status

      rescue JSON::ParserError

        render json:{
          success:false,
          message: response.body
        }, status:500

      end


    rescue JSON::ParserError

      render json:{
        success:false,
        message:'JSON inválido'
      }, status:422

    end

    private

    def gerar_token_sso(payload)
      header = {
        alg: 'HS256',
        typ: 'JWT'
      }

      header_base64 = base64_url_encode(header.to_json)
      payload_base64 = base64_url_encode(payload.to_json)

      dados_assinados = "#{header_base64}.#{payload_base64}"

      assinatura = OpenSSL::HMAC.digest(
        'SHA256',
        ENV.fetch('ISOPRIME_KANBAN_SSO_SECRET'),
        dados_assinados
      )

      assinatura_base64 = base64_url_encode(assinatura)

      "#{dados_assinados}.#{assinatura_base64}"
    end

    def base64_url_encode(data)
      Base64.urlsafe_encode64(data).delete('=')
    end

  end
end