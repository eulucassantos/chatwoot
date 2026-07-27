<script setup>
import Button from 'dashboard/components-next/button/Button.vue';

defineProps({
    show: {
        type: Boolean,
        default: false,
    },

    stages: {
        type: Array,
        default: () => [],
    },
});


const emit = defineEmits([
    'close',
    'select',
]);


const selecionar = stage => {
    emit('select', stage);
};


const fechar = () => {
    emit('close');
};

</script>


<template>

    <div v-if="show" class="fixed inset-0 z-[9999] flex items-center justify-center">


        <!-- Fundo -->

        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="fechar" />



        <!-- Modal -->

        <div class="relative w-[380px] rounded-2xl bg-n-surface-1 border border-n-weak shadow-2xl p-5">



            <!-- Cabeçalho -->

            <div class="flex items-center gap-3 mb-5">


                <div class="flex items-center justify-center size-10 rounded-xl bg-[#2873D1]">
                    <i class="i-lucide-kanban text-white text-xl" />
                </div>



                <div>

                    <h3 class="font-semibold text-n-slate-12">
                        Alterar etapa da negociação
                    </h3>


                    <p class="text-xs text-n-slate-11">
                        Selecione uma etapa do funil
                    </p>

                </div>


            </div>



            <!-- Etapas -->

            <div v-if="stages.length" class="flex flex-col gap-2">


                <button v-for="stage in stages" :key="stage.id"
                    class="flex items-center gap-3 p-3 rounded-xl border border-n-weak hover:bg-n-alpha-2 transition"
                    @click="selecionar(stage)">

                    <span class="size-3 rounded-full" :style="{
                        backgroundColor: stage.color
                    }" />

                    <div class="flex flex-col text-left">

                        <span class="font-bold text-sm text-n-slate-12">
                            {{ stage.name }}
                        </span>

                        <span class="text-xs text-n-slate-10">
                            {{ stage.tag }}
                        </span>

                    </div>

                </button>


            </div>



            <!-- Sem etapas -->

            <div v-else class="rounded-xl border border-n-weak p-4 text-center">

                <p class="text-sm text-n-slate-11">
                    Nenhuma etapa disponível.
                </p>

            </div>



            <!-- Fechar -->

            <Button class="mt-4 w-full" slate label="Cancelar" @click="fechar" />


        </div>


    </div>


</template>