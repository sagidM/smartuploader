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



## License
Released under the [MIT license](https://opensource.org/licenses/MIT).
