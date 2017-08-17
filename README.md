# smartuploader
jQuery plugin for upload files



```html
<script src="https://github.com/kofon95/smartuploader/blob/master/jquery.smartuploader.coffee"></script>
<script>
$("#file_input").withDropZone("#drop_zone", {
  url: "/some_common_page",
  uploadBegin: function(fileIndex, blob) {
  },
  uploadEnd: function(fileIndex, blob) {
  },
  done: function(){
  },
  multiUploading: false,
  action: {
    name: "image",
    rename: function(filenameWithoutExt, ext, fileIndex) {
      return filenameWithoutExt + ".jpg"
    },
    params: {
      preview: true,
      convertTo: {
        mimeType: "image/jpeg",
        maxWidth: 150,
        maxHeight: 150,
      },
    }
  },
  ifWrongFile: "show",
  wrapperForInvalidFile: function(fileIndex) {
    return `<div style="margin: 20px 0; color: red;">File: "${file.name}" doesn't support</div>`
  },
  ajaxSettings: function(settings, index, filename, blob){
    // settings.url = "/some_specific_page"
    settings.data.set("user_id", "0")
    settings.error = function(e) {
      if (e.status === 0) {
        return alert("Check your internet connection");
      } else if (e.status >= 400 && e.status < 500) {
        return alert(`Server page not found: ${e.status}`);
      } else {
        return alert(`Server error: ${e.status}`);
      }
    }
  }
});
</script>
<form enctype="multipart/form-data" action="" method="post">
  <div id="drop_zone" class="drop-zone">
    <p class="title">Drop file here</p>
    <div class="preview-container"></div>
  </div>
  <input id="file_input" accept="image/*" type="file" multiple="" name="file">
</form>
<style>
.drop-zone {
  cursor: pointer;
  color: #555;
  font-size: 18px;
  text-align: center;
  width: 400px;
  padding: 50px 0;
  margin: 50px auto;
  border: 2px dashed #0087F7;
  border-radius: 5px;
  background: white;
}
.drop-zone.hover {
  background: #ddd;
  border-color: #aaa;
}
.drop-zone.error {
  background: #faa;
  border-color: #f00;
}
.drop-zone.drop {
  background: #afa;
  border-color: #00a1ff;
}
.drop-zone.drop > .title {
  display: none;
}
.preview-container canvas {
  width: 150px;
}
.file-uploader-progress-bar {
  margin: 0 20px;
}
.file-uploader-progress-bar > * {
  background-color: #71a5f3;
  width: 0;
  height: 5px;
  border-radius: 5px;
}
.file-uploader-progress-bar.loading > * {
  background-color: #8c8c8c;
}
</style>
```

```css

```



# So the result is


<form enctype="multipart/form-data" action="" method="post">
  <div id="drop_zone" class="drop-zone">
    <p class="title">Drop file here</p>
    <div class="preview-container"></div>
  </div>
  <input id="file_input" accept="image/*" type="file" multiple="" name="file">
</form>

<style>
.drop-zone {
  cursor: pointer;
  color: #555;
  font-size: 18px;
  text-align: center;
  width: 400px;
  padding: 50px 0;
  margin: 50px auto;
  border: 2px dashed #0087F7;
  border-radius: 5px;
  background: white;
}
.drop-zone.hover {
  background: #ddd;
  border-color: #aaa;
}
.drop-zone.error {
  background: #faa;
  border-color: #f00;
}
.drop-zone.drop {
  background: #afa;
  border-color: #00a1ff;
}
.drop-zone.drop > .title {
  display: none;
}
.preview-container canvas {
  width: 150px;
}
.file-uploader-progress-bar {
  margin: 0 20px;
}
.file-uploader-progress-bar > * {
  background-color: #71a5f3;
  width: 0;
  height: 5px;
  border-radius: 5px;
}
.file-uploader-progress-bar.loading > * {
  background-color: #8c8c8c;
}
</style>

# It converts your image into "jpeg" 150x150 (fill) and make post query to it's page