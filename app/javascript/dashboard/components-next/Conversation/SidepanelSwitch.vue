<script setup>
import Button from 'dashboard/components-next/button/Button.vue';
import ButtonGroup from 'dashboard/components-next/buttonGroup/ButtonGroup.vue';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { computed, ref } from 'vue';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';
import { useMapGetter } from 'dashboard/composables/store';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';
import ConversationPipelineModal from 'dashboard/components-next/ConversationWorkflow/ConversationPipelineModal.vue';
import { useStoreGetters } from 'dashboard/composables/store';


const { updateUISettings } = useUISettings();

const currentAccountId = useMapGetter('getCurrentAccountId');

const isFeatureEnabledonAccount = useMapGetter(
  'accounts/isFeatureEnabledonAccount'
);

const currentUser = useMapGetter('getCurrentUser');

const { uiSettings } = useUISettings();


const isContactSidebarOpen = computed(
  () => uiSettings.value.is_contact_sidebar_open
);


const isCopilotPanelOpen = computed(
  () => uiSettings.value.is_copilot_panel_open
);


const showCopilotTab = computed(() =>
  isFeatureEnabledonAccount.value(
    currentAccountId.value,
    FEATURE_FLAGS.CAPTAIN
  )
);

const getters = useStoreGetters();

const currentChat = computed(
  () => getters.getSelectedChat.value
);

const toggleConversationSidebarToggle = () => {

  updateUISettings({
    is_contact_sidebar_open: !isContactSidebarOpen.value,
    is_copilot_panel_open: false,
  });

};



const handleConversationSidebarToggle = () => {

  updateUISettings({
    is_contact_sidebar_open: true,
    is_copilot_panel_open: false,
  });

};



const handleCopilotSidebarToggle = () => {

  updateUISettings({
    is_contact_sidebar_open: false,
    is_copilot_panel_open: true,
  });

};



// ===============================
// CRM / FUNIL
// ===============================


const showPipelineModal = ref(false);

const pipelineStages = ref([]);



const buscarEtapasFunil = async () => {

  try {

    const response = await fetch(
      `/isoprime/kanban/colunas?user_id=${currentUser.value.id}`
    );

    if (!response.ok) {
      console.error('Erro ao buscar etapas:', response.status);
      return;
    }

    const data = await response.json();

    if (data.success) {

      pipelineStages.value = data.columns
        .filter(coluna => coluna.label)
        .map(coluna => ({
          id: coluna.id,
          key: coluna.key,
          name: coluna.title,
          tag: coluna.label,
          color: coluna.color
        }));

    }

  } catch (error) {

    console.error('Erro comunicação Kanban:', error);

  }

};



const abrirEtapaNegociacao = async () => {

  if (!currentChat.value?.id) {
    return;
  }

  await buscarEtapasFunil();

  if(pipelineStages.value.length){
    showPipelineModal.value = true;
  }

};



const alterarEtapa = async(stage) => {

    if (!currentChat.value?.id || !stage?.key) {
        return;
    }

    const conversaId = currentChat.value.id;


    await fetch(
        `/isoprime/kanban/conversas/${conversaId}/etapa?user_id=${currentUser.value.id}`,
        {
            method:'PATCH',
            headers:{
                'Content-Type':'application/json',
                Accept:'application/json'
            },
            body:JSON.stringify({
                etapa_funil: stage.key
            })
        }
    );

    if (!response.ok) {
      console.error('Erro ao alterar etapa:', response.status);
      return;
    }

    showPipelineModal.value = false;

};



// ===============================
// ATALHOS
// ===============================


const keyboardEvents = {

  'Alt+KeyO': {

    action: toggleConversationSidebarToggle,

  },

};


useKeyboardEvents(keyboardEvents);

</script>



<template>

  <ButtonGroup
    class="flex flex-col justify-center items-center absolute top-36 xl:top-24 ltr:right-2 rtl:left-2 bg-n-solid-2/90 backdrop-blur-lg border border-n-weak/50 rounded-full gap-1.5 p-1.5 shadow-sm transition-shadow duration-200 hover:shadow">


    <!-- CONTATO -->

    <Button v-tooltip.top="$t('CONVERSATION.SIDEBAR.CONTACT')" sm
      class="!rounded-full !bg-[#2873D1] !text-white transition-all duration-[250ms] ease-out hover:!bg-[#0D54BD] active:!scale-95 active:!brightness-105"
      :class="{
        'shadow-md ring-2 ring-[#2873D1]/30': isContactSidebarOpen,
      }" icon="i-ph-user-bold" @click="handleConversationSidebarToggle" />



    <!-- CRM FUNIL -->

    <Button v-tooltip.top="'Alterar etapa da negociação'" sm
      class="!rounded-full !bg-[#2873D1] !text-white transition-all duration-[250ms] ease-out hover:!bg-[#0D54BD] active:!scale-95 active:!brightness-105"
      icon="i-lucide-kanban" @click="abrirEtapaNegociacao" />



    <!-- COPILOT -->

    <Button v-if="showCopilotTab" v-tooltip.bottom="$t('CONVERSATION.SIDEBAR.COPILOT')" ghost slate sm
      class="!rounded-full transition-all duration-[250ms] ease-out active:!scale-95 active:!duration-75" :class="{
        'bg-n-alpha-2 !text-n-iris-9 active:!brightness-105 active:!shadow-sm':
          isCopilotPanelOpen,
      }" icon="i-woot-captain" @click="handleCopilotSidebarToggle" />


  </ButtonGroup>



  <!-- MODAL CRM -->

  <ConversationPipelineModal :show="showPipelineModal" :stages="pipelineStages" @close="showPipelineModal = false"
    @select="alterarEtapa" />


</template>