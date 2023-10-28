Memo:

1. Render lobby.blend and export as video (?)

2. Convert to mp4 with

```
ffmpeg -i render.mkv -an -vcodec libx264 -pix_fmt yuv420p -preset slow -profile:v baseline -movflags faststart new-lobby.mp4
```
(see: https://stackoverflow.com/a/24697998)

3. Export fallback image with
```
ffmpeg -i new-lobby.mp4 -vf "select=eq(n\,120)" -vframes 1 new-lobby.png
```

---


Todo: 

1. https://www.byond.com/forum/post/2755147 (so we can enable animation by default)

2. Fix artefacts in NY version

3. Halloween version
