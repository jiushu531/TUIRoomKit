<!--
  * Name: VideoTab
  * @param name String required
  * @param size String 'large'|'medium'|'small'
  * Usage:
  * Use <video-tab></video-tab> in the template
  *
  * 名称: VideoTab
  * @param name String required
  * @param size String 'large'|'medium'|'small'
  * 使用方式：
  * 在 template 中使用 <video-tab></video-tab>
-->
<template>
  <div :class="['video-tab', themeClass]">
    <div class="item-setting">
      <span class="title">{{ t('Camera') }}</span>
      <device-select device-type="camera"></device-select>
    </div>
    <div v-if="withPreview" class="item-setting">
      <span class="title">{{ t('Preview') }}</span>
      <div class="video-preview-container">
        <div id="test-camera-preview" class="video-preview"></div>
      </div>
    </div>
    <div class="item-setting">
      <span class="title">{{ t('Resolution') }}</span>
      <video-profile></video-profile>
    </div>
    <div class="mirror-container">
      <span>{{ t('Mirror') }}</span>
      <tui-switch v-model="isLocalStreamMirror"></tui-switch>
    </div>
    <div v-if="withMore" class="item-setting">
      <!-- TODO: <div class="item">美颜与虚拟背景</div> -->
      <div class="item" @click="handleMoreCameraSetting">{{ t('More Camera Settings') }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, Ref, watch, onMounted, onUnmounted, computed } from 'vue';
import DeviceSelect from './DeviceSelect.vue';
import VideoProfile from './VideoProfile.vue';
import TuiSwitch from './base/TuiSwitch.vue';
import { useBasicStore } from '../../stores/basic';
import { useI18n } from '../../locales';

import useGetRoomEngine from '../../hooks/useRoomEngine';

import { TRTCVideoMirrorType, TRTCVideoRotation, TRTCVideoFillMode } from '@tencentcloud/tuiroom-engine-uniapp-app';
import { isElectron, isMobile, isApp }  from '../../utils/environment';
import { storeToRefs } from 'pinia';
const roomEngine = useGetRoomEngine();

interface Props {
  withPreview?: boolean,
  withMore?: boolean,
  withMirror?: boolean,
  theme?: 'white' | 'black',
}
const props = defineProps<Props>();

const basicStore = useBasicStore();
const { isLocalStreamMirror } = storeToRefs(basicStore);

const themeClass = computed(() => (props.theme ? `tui-theme-${props.theme}` : ''));

watch(isLocalStreamMirror, async (val: boolean) => {
  const trtcCloud = roomEngine.instance?.getTRTCCloud();
  if (!isMobile || !isApp) {
    await trtcCloud?.setLocalRenderParams({
      mirrorType: val
        ? TRTCVideoMirrorType.TRTCVideoMirrorType_Enable : TRTCVideoMirrorType.TRTCVideoMirrorType_Disable,
      rotation: TRTCVideoRotation.TRTCVideoRotation0,
      fillMode: TRTCVideoFillMode.TRTCVideoFillMode_Fill,
    });
  }
});

const { t } = useI18n();

/**
 * Click [More Camera Settings].
 *
 * 点击【更多摄像头设置】
**/
function handleMoreCameraSetting() {
  basicStore.setShowSettingDialog(true);
  basicStore.setActiveSettingTab('video');
}

if (props.withPreview) {
  onMounted(async () => {
    roomEngine.instance?.startCameraDeviceTest({ view: 'test-camera-preview' });
    if (isElectron) {
      // Electron 需要首次设置 mirrorType
      const trtcCloud = roomEngine.instance?.getTRTCCloud();
      await trtcCloud?.setLocalRenderParams({
        mirrorType: isLocalStreamMirror.value
          ? TRTCVideoMirrorType.TRTCVideoMirrorType_Enable : TRTCVideoMirrorType.TRTCVideoMirrorType_Disable,
        rotation: TRTCVideoRotation.TRTCVideoRotation0,
        fillMode: TRTCVideoFillMode.TRTCVideoFillMode_Fill,
      });
    }
  });

  onUnmounted(() => {
    roomEngine.instance?.stopCameraDeviceTest();
  });
}

</script>

<style lang="scss" scoped>
.video-tab {
  border-radius: 8px;
  font-size: 14px;
  .title {
    margin-bottom: 8px;
    width: 100%;
    color: #4F586B;
    font-size: 14px;
    font-weight: 400;
    line-height: 22px;
  }
  .video-preview-container {
    position: relative;
    width: 100%;
    height: 0;
    padding-top: calc(100% * 9 / 16);
    background-color: #000000;
    border-radius: 8px;
    overflow: hidden;
    .video-preview {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
    }
  }
  .mirror-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: #4F586B;
    font-size: 14px;
    font-style: normal;
    font-weight: 400;
    line-height: 22px;
    padding-right: 2px;
  }
  .item {
    width: 100%;
    height: 20px;
    color: #000000;
  }
}
</style>
