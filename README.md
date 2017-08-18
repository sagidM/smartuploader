smartuploader
===============

jQuery plugin for upload files


## Features
* **Multiple file upload:**  
  Allows to select multiple files at once and upload them simultaneously.
* **Drag & Drop support:**  
  Allows to upload files by dragging them from your desktop or filemanager and dropping them on your browser window.
* **Upload progress bar:**  
  Shows a progress bar indicating the upload progress for individual files.
* **Client-side image convert and resizing:**  
  Images can be automatically convert into JPEG, PNG, WEBP and resized on client-side with browsers supporting the required JS APIs.
* **Preview images (other formats are going to be):**  
  A preview of image can be displayed before uploading with browsers supporting the required APIs.
* **No browser plugins (e.g. Adobe Flash) required:**  
  The implementation is based on open standards like HTML5 and JavaScript and requires no additional browser plugins.


## Deployment

### __To compile to js__
```
$ npm install --global coffeescript

$ coffee -wc jquery.smartuploader.coffee # watch and compile
$ coffee -c jquery.smartuploader.coffee  # just compile
```
_it creates **jquery.smartuploader.js** in the root_

#### More information [https://www.npmjs.com/package/coffee-script](https://www.npmjs.com/package/coffee-script)

### __Online service__

Use CoffeeScript official website: [http://coffeescript.org/#try:%23%20Paste%20CoffeeScript%20code%20here](http://coffeescript.org/#try:%23%20Paste%20CoffeeScript%20code%20here)




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


## License
Released under the [MIT license](https://opensource.org/licenses/MIT).
