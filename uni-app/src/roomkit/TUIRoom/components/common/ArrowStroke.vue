<template>
  <div :class="arrowStrokeClass">
    <div :class="['stroke-content', { 'has-stroke': hasStroke }]">
      <div class="arrow-content" @click="handleClickArrow">
      </div>
    </div>
    <svg-icon style="display: flex" :class="['arrow', { 'has-stroke': hasStroke }]" @click="handleClickArrow">
      <arrow-stroke-left-icon :class="arrowDirection"></arrow-stroke-left-icon>
    </svg-icon>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import SvgIcon from './base/SvgIcon.vue';
import ArrowStrokeLeftIcon from '../../assets/icons/ArrowStrokeLeftIcon.png';

interface Props {
  // 'bottom' | 'left'
  strokePosition: string;
  // 'up' | 'down' | 'left' | 'right'
  arrowDirection: string;
  // 是否展示线条
  hasStroke: boolean,
}

const props = defineProps<Props>();

const emits = defineEmits(['click-arrow']);

const arrowStrokeClass = computed(() => `arrow-stroke-container-${props.strokePosition}`);

function handleClickArrow() {
  emits('click-arrow');
}

</script>

<style lang="scss" scoped>
.arrow-stroke-container-left {
  width: 8px;
  height: 100%;
  .stroke-content {
    width: 100%;
    height: 100%;
    position: absolute;
    background-color: transparent;
    transform: perspective(20px) rotateX(0deg) rotateY(-20deg) translateZ(0);
    .arrow-content {
      width: 5px;
      height: 60px;
      position: absolute;
      top: 50%;
      left: 0px;
      transform: translateY(-50%);
      &::before {
        width: 20px;
        height: 100%;
        position: absolute;
        top: 0;
        right: -15px;
        border-top-left-radius: 10px;
        border-bottom-left-radius: 10px;
        border: 1px solid rgba(143, 154, 178, 0.10);
        background-color: rgba(15, 16, 20, 0.30);
      }
    }
    &.has-stroke {
      .arrow-content {
        width: 5px;
        height: 60px;
        position: absolute;
        top: 50%;
        left: 0px;
        transform: translateY(-50%);
        border-top: 1px solid #E4EAF7;
        border-left: 1px solid #E4EAF7;
        border-bottom: 1px solid #E4EAF7;
        border-top-left-radius: 4px;
        border-bottom-left-radius: 4px;
        &::before {
          width: 20px;
          height: 100%;
          position: absolute;
          top: 0;
          right: -15px;
          border: 0px;
          background-color: transparent;
        }
      }
      &::before {
        width: 2px;
        height: calc((100% - 60px) / 2);
        position: absolute;
        top: 0px;
        right: 0px;
        border-right: 1px solid #E4EAF7;
        border-bottom: 1px solid #E4EAF7;
        border-bottom-right-radius: 4px;
      }
      &::after {
        width: 2px;
        height: calc((100% - 60px) / 2);
        position: absolute;
        bottom: 0px;
        right: 0px;
        border-right: 1px solid #E4EAF7;
        border-top: 1px solid #E4EAF7;
        border-top-right-radius: 4px;
      }
    }
  }
  .arrow {
    position: absolute;
    top: 50%;
    left: 6px;
    transform: translateY(-50%);
    color: #D5E0F2;
    transition: color 0s;
    svg {
      transition: color 0s;
    }
  }
}

.arrow-stroke-container-bottom {
  width: 100%;
  height: 8px;
  .stroke-content {
    width: 100%;
    height: 100%;
    position: absolute;
    background-color: transparent;
    transform: perspective(20px) rotateX(-20deg) rotateY(0deg) translateZ(0);
    .arrow-content {
      width: 60px;
      height: 5px;
      position: absolute;
      left: 50%;
      bottom: 0px;
      transform: translateX(-50%);
      &::before {
        width: 100%;
        height: 20px;
        position: absolute;
        bottom: 0;
        border-bottom-left-radius: 10px;
        border-bottom-right-radius: 10px;
        border: 1px solid rgba(143, 154, 178, 0.10);
        background-color: rgba(15, 16, 20, 0.30);
      }
    }
    &.has-stroke {
      .arrow-content {
        width: 60px;
        height: 5px;
        position: absolute;
        left: 50%;
        bottom: 0px;
        transform: translateX(-50%);
        border-left: 1px solid #E4EAF7;
        border-bottom: 1px solid #E4EAF7;
        border-right: 1px solid #E4EAF7;
        border-bottom-left-radius: 4px;
        border-bottom-right-radius: 4px;
        .arrow {
          color: #A4BBDB;
        }
        &::before {
          width: 100%;
          height: 20px;
          position: absolute;
          bottom: 0;
          border: 0px;
          background-color: transparent;
        }
      }
      &::before {
        width: calc((100% - 60px) / 2);
        height: 2px;
        position: absolute;
        top: 0px;
        left: 0px;
        border-top: 1px solid #E4EAF7;
        border-right: 1px solid #E4EAF7;
        border-top-right-radius: 4px;
      }
      &::after {
        width: calc((100% - 60px) / 2);
        height: 2px;
        position: absolute;
        top: 0px;
        right: 0px;
        border-left: 1px solid #E4EAF7;
        border-top: 1px solid #E4EAF7;
        border-top-left-radius: 4px;
      }
    }
  }
  .arrow {
      position: absolute;
      left: 50%;
      bottom: 4px;
      transform: translateX(-50%);
      color: #D5E0F2;
      transition: color 0s;
      svg {
        transition: color 0s;
      }
    }
}

.up {
  transform: rotate(90deg);
}
.left {
  transform: rotate(0deg);
}
.down {
  transform: rotate(-90deg);
}
.right {
  transform: rotate(180deg);
}

</style>
