<template>
  <div
    class="member-item-container"
    @mouseenter="openMemberControl"
    @mouseleave="closeMemberControl"
  >
    <member-info
      :user-info="props.userInfo"
      :show-state-icon="props.userInfo.isInRoom && !showMemberControl"
    />
    <member-control
      v-show="showMemberControl && props.userInfo.isInRoom"
      :show-member-control="showMemberControl"
      :user-info="props.userInfo"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch, defineProps } from 'vue';
import MemberInfo from '../MemberItemCommon/MemberInfo.vue';
import MemberControl from '../MemberControl';
import { UserInfo } from '../../../stores/room';
import useMemberItem from './useMemberItemHooks';

interface Props {
  userInfo: UserInfo;
}

const props = defineProps<Props>();

const { isMemberControlAccessible, openMemberControl, closeMemberControl } =
  useMemberItem(props.userInfo);

const showMemberControl = ref(false);

watch(isMemberControlAccessible, (accessible: boolean) => {
  showMemberControl.value = accessible;
});
</script>

<style lang="scss" scoped>
.member-item-container {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  height: 52px;
  padding: 0 20px;

  &:hover {
    cursor: pointer;
    background-color: var(--list-color-hover);
  }
}
</style>
