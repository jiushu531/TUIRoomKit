<template>
  <TuiDialog
    v-model="showRoomInvite"
    :title="t('Schedule successful, invite members to join')"
    :modal="true"
    :show-close="true"
    :close-on-click-modal="true"
    width="540px"
    :append-to-body="true"
    :title-icon="SuccessIcon"
  >
    <div class="invite-member">
      <div
        v-for="item in scheduleInviteList"
        :key="item.id"
        class="invite-member-container"
      >
        <div class="invite-member-title">{{ t(item.title) }}</div>
        <div class="invite-member-item">
          <span class="invite-member-content"> {{ item.content }}</span>
          <svg-icon
            style="display: flex"
            class="copy"
            :icon="copyIcon"
            @click="onCopy(item.content)"
          />
        </div>
      </div>
    </div>
    <template #footer>
      <span>
        <tui-button
          class="dialog-button"
          size="default"
          @click="copyRoomIdAndRoomLink()"
          >{{ t('Copy the conference number and link') }}
        </tui-button>
      </span>
    </template>
  </TuiDialog>
</template>

<script setup lang="ts">
import { ref, defineProps, watch, computed, defineEmits } from 'vue';
import { storeToRefs } from 'pinia';
import { useI18n } from '../../locales';
import TuiDialog from '../common/base/Dialog/index.vue';
import TuiButton from '../common/base/Button.vue';
import SuccessIcon from '../../assets/icons/SuccessIcon.svg';
import { TUIConferenceInfo } from '@tencentcloud/tuiroom-engine-wx';
import copyIcon from '../../assets/icons/CopyIcon.svg';
import SvgIcon from '../common/base/SvgIcon.vue';
import useRoomInfo from '../RoomHeader/RoomInfo/useRoomInfoHooks';
import { getUrlWithRoomId } from '../../utils/utils';
import { useBasicStore } from '../../stores/basic';
import { roomService } from '../../services';

const basicStore = useBasicStore();
const { isRoomLinkVisible } = storeToRefs(basicStore);
const roomLinkConfig = roomService.getComponentConfig('RoomLink');
const { t } = useI18n();
const { onCopy } = useRoomInfo();

interface Props {
  conferenceInfo?: TUIConferenceInfo;
  scheduleParams?: any;
  visible: boolean;
}
const props = defineProps<Props>();
const emit = defineEmits(['input', 'close']);
const showRoomInvite = ref(false);

watch(
  () => props.visible,
  val => {
    showRoomInvite.value = val;
  },
  {
    immediate: true,
  }
);

const updateVisible = (val: boolean) => {
  emit('input', val);
};

const roomType = computed(() =>
  props.scheduleParams.isSeatEnabled
    ? `${t('On-stage Speaking Room')}`
    : `${t('Free Speech Room')}`
);

const isShowPassword = computed(() => !!props.scheduleParams.password);

function copyRoomIdAndRoomLink() {
  const invitationList = [
    `${props.scheduleParams.roomName}`,
    `${t('Room Type')}: ${roomType.value}`,
    `${t('Room ID')}: ${props.scheduleParams.roomId}`,
  ];
  if (isShowPassword.value) {
    invitationList.push(
      `${t('Room Password')}: ${props.scheduleParams.password}`
    );
  }
  if (isRoomLinkVisible.value && roomLinkConfig.visible) {
    invitationList.push(
      `${t('Room Link')}: ${getUrlWithRoomId(props.scheduleParams.roomId)}`
    );
  }

  const invitation = invitationList.join('\n');
  onCopy(invitation);
}

const scheduleInviteList = computed(() => [
  {
    id: 1,
    title: `${t('Invitation by room ID')}`,
    content: props.scheduleParams.roomId,
  },
  {
    id: 2,
    title: `${t('Invitation via room link')}`,
    content: getUrlWithRoomId(props.scheduleParams.roomId),
  },
]);

watch(
  showRoomInvite,
  val => {
    updateVisible(val);
  },
  { immediate: true }
);
</script>

<style lang="scss" scoped>
.invite-member {
  display: flex;
  flex-direction: column;
  gap: 20px;
  user-select: none;

  .invite-member-title {
    color: var(--text-color-primary);
  }

  .invite-member-item {
    display: flex;
    justify-content: space-between;
    padding: 10px 16px;
    margin-top: 8px;
    border-radius: 8px;
    background-color: var(--bg-color-input);
    color: var(--text-color-primary);
    border: 1px solid var(--stroke-color-module);

    .invite-member-content {
      max-width: 400px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .copy {
      width: 20px;
      height: 20px;
      cursor: pointer;
      color: var(--text-color-link);
    }
  }
}
</style>
