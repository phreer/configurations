#!/bin/bash
# Run Google Chrome with arguments to enable hardware decoding for AMD GPU.

CHROME=/opt/google/chrome/google-chrome
"$CHROME" --use-gl=angle --use-angle=vulkan \
  --enable-accelerated-video-decode \
  --enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,UseMultiPlaneFormatForHardwareVideo \
  "$@"
