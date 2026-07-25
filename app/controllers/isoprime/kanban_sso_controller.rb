# frozen_string_literal: true

module Isoprime
  class KanbanSsoController < ApplicationController
    before_action :authenticate_user!

    def show
      account_id = ENV.fetch('ISOPRIME_CHATWOOT_ACCOUNT_ID', '1').to_i
      account_user = current_user.account_users.find_by(account_id: account_id)

      return head :forbidden unless account_user

      payload = {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        role: account_user.role,
        account_id: account_id,
        iat: Time.current.to_i,
        exp: 60.seconds.from_now.to_i
      }

      token = gerar_token_sso(payload)

      kanban_url = ENV.fetch(
        'ISOPRIME_KANBAN_URL',
        'https://projeto-isoprime-kanban.iuw3ed.easypanel.host'
      )

      redirect_to "#{kanban_url}/auth/chatwoot/sso?token=#{token}", allow_other_host: true
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