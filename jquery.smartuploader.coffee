###
 jQuery Smart Uploader Plugin 0.4.0
 https://github.com/kofon95/smartuploader

 Licensed under the MIT license:
 http://www.opensource.org/licenses/MIT
###

$ = jQuery


DefaultOptions = {
  url: null
  action: null
  multiUploading: true
  ifWrongFile: "show"
  maxFileSize: Number.POSITIVE_INFINITY
  autoUpload: no
  fileNameMatcher: /.*/      # /^[^\.].*\..*[^\.]$/  # .wrong; also.wrong.; good.txt
  fileMimeTypeMatcher: /.*/
  wrapperForInvalidFile: (fileIndex) ->
    "<p>File: \"#{this.files[fileIndex].name}\" doesn't support</p>'"
  validateEach: (fileIndex) -> true            # should return Boolean
  validateAll: (files) -> files                # should return array of valid files
  # formData: (fileIndex, blob, filename) ->   # if single upload, it's called once
  # formData: (blobs, filenames) ->            # if multi upload, it's called for each file
  # ~70 line
  uploadBegin: (fileIndex, blob) ->
  uploadEnd: (fileIndex, blob) ->
  done: () ->
  ajaxSettings: (settings, fileIndex, blob)->
}
ifWrongFileParams = ["nothing", "error", "show", "ignore"]

DropZoneError = (message) ->
  this.message = message
DropZoneError.prototype = new Error

extract = (field, self, args) ->
  if typeof field is "function"
    field.apply(self, args)
  else
    field

empty = ->

$.fn.withDropZone = (dropZone, options) ->
  if this.attr("type") isnt "file"
    throw new DropZoneError("You should call this method only on input[type=file] and send dropZone as argument")
  dropZone = $(dropZone) unless dropZone instanceof $


  # settings up options
  if options
    for key, value of DefaultOptions
      options[key] = value unless options.hasOwnProperty(key)

    if !options.ifWrongFile
      options.ifWrongFile = "show"
    else if ifWrongFileParams.indexOf(options.ifWrongFile) < 0
      throw new DropZoneError('"ifWrongFile" should has one of these values: "nothing", "error", "show", "ignore"')

    if !options.formData
      if options.multiUploading
        options.formData = (fileIndex, blob, filename) ->
          formData = new FormData
          formData.set(this.name, blob, filename)
          formData
      else
        options.formData = (blobs, filenames) ->
          formData = new FormData
          for i in [0...blobs.length]
            formData.append(this.name, blobs[i], filenames[i])
          formData
  else
    options = {}



#####################################
  workers = []

  fileInput = this.get(0)

  dropZone
    .on("dragenter", ->
      dropZone.addClass('hover')
    )
    .on("dragleave", (e) ->
      dropZone.removeClass('hover')
    )
    .on('dragover',(e) ->
      e.preventDefault()
    )
    .on("drop", (e) ->
      e.preventDefault()
      fileInput.files = e.originalEvent.dataTransfer.files
      uploadImageFiles(this, fileInput, workers, fileInput.files, options)
    )
    .on("click", -> fileInput.click())

  this.on("change", ->
    uploadImageFiles(dropZone[0], this, workers, this.files, options)
  )

  return {
    upload: ->
      for worker in workers
        worker()
    autoUpload: (value)->
      return options.autoUpload unless value?
      options.autoUpload = value
    waitingToUploadCount: -> workers.length
  }


# both dropZone and fileInput are instances of HTMLElement
uploadImageFiles = (dropZone, fileInput, workers, files, options) ->
  workers.length = 0;
  dropZone.classList.remove 'hover'
  dropZone.classList.remove 'drop'
  dropZone.classList.remove 'error'

  previewContainer = dropZone.getElementsByClassName("preview-container")[0]
  previewContainer.innerHTML = "" if previewContainer
  return if files.length is 0


  droppedFiles = []


  # when user drops files, they doesn't care about "multiple"
  unless fileInput.multiple
    files = files.slice 0, 1


  # if user drops files, "accept" of file input doesn't work
  accept = (fileInput.accept || "")
    .split(",")
    .map (accept) -> "(#{accept.replace('*', '.*')})"
    .join("|")
  accept = new RegExp accept

  # validation

  files = options.validateAll.call(fileInput, file for file in files)
  isValidFile = []
  nameMatcher = options.fileNameMatcher
  mimeTypeMatcher = options.fileMimeTypeMatcher
  msize       = options.maxFileSize

  anyIsInvalid = false
  for file in files
    isValid = options.validateEach(file)      and
              accept.test(file.type)          and
              nameMatcher.test(file.name)     and
              mimeTypeMatcher.test(file.type) and
              msize >= file.size
    isValidFile.push(isValid)
    anyIsInvalid = true unless isValid

  if anyIsInvalid
    if options.ifWrongFile is "error"
      fileInput.value = null
      dropZone.classList.add 'error'
      return
    if options.ifWrongFile is "nothing"
      fileInput.value = null
      return


  dropZone.classList.add('drop')
  if previewContainer
    previewContainer.innerHTML = ""
  else
    previewContainer = document.createElement("div")
    previewContainer.className = "preview-container";
    dropZone.append(previewContainer)


  multiUploading = options.multiUploading
  blobs = []  # only for single uploading
  filenames = new Array(files.length)
  uploadedFilesCount = 0
  ignore = options.ifWrongFile is "ignore"
  for i in [0...files.length]
    if !isValidFile[i] and ignore
      continue
    `
    let file = files[i]
    let fileIndex = i
    let wrapper = document.createElement("div")
    let preview
    let progressBar
    `

    wrapper.className = "wrapper uploading"
    previewContainer.append(wrapper)

    unless isValidFile[i]
      wrapper.classList.add "invalid"
      wrapper.innerHTML = options.wrapperForInvalidFile.call(fileInput, fileIndex)
      continue


    wrapper.innerHTML = '''
      <div class="preview"></div>
      <div class="file-name"></div>
      <div class="file-uploader-progress-bar">
        <div class="progress"></div>
      </div>
    '''
    kids = wrapper.children
    preview = kids[0]
    kids[1].textContent = file.name
    progressBar = kids[2].children[0]



    # ajax request
    uploadNext = (blob)->
      workers.push ->
        process = (progress) ->
          progressBar.style.width = 100 * progress.loaded / progress.total + "%"

        if multiUploading
          formDataResult = options.formData.call(fileInput, fileIndex, blob, filenames[fileIndex])
          uploadQuery(options, formDataResult, filenames[fileIndex], fileInput, fileIndex, blob, process).done ->
            wrapper.classList.remove "uploading"
            options.uploadEnd.call(fileInput, filenames[fileIndex], fileIndex, blob)
            if ++uploadedFilesCount is files.length
              options.done.call(fileInput, filenames)
        else
          blobs.push(blob)
          if ++uploadedFilesCount is files.length
            formDataResult = options.formData.call(fileInput, blobs, filenames)
            uploadQuery(options, formDataResult, filenames, fileInput, "(multiUploading must be true)", blobs, process).done ->
              options.uploadEnd.call(fileInput, filenames, fileIndex, blob)
              options.done.call(fileInput, filenames)
      workers[workers.length-1]() if options.autoUpload



    filenames[fileIndex] = file.name
    actionOption = extract(options.action, fileInput, [i])
    if actionOption
      action = actions[actionOption.name]
      if typeof action isnt "function"
        unless actionOption.name?
          throw new DropZoneError('Please, specify "name" in "action" block')
        throw new DropZoneError("There'no action with name \"#{actionOption.name}\"")
      if actionOption.rename
        dotPos = file.name.indexOf(".")
        if dotPos < 0
          name = file.name
          ext = ""
        else
          name = file.name.substr(0, dotPos)
          ext = file.name.substr(dotPos)
        filenames[fileIndex] = actionOption.rename.call(fileInput, name, ext, fileIndex)

      if !actionOption.params
        throw new DropZoneError('You should specify "params" in "action" option')
      action(options, actionOption.params, preview, file, uploadNext)
    else
      uploadNext(file)

  null # end function


uploadQuery = (options, formDataResult, filename, fileInput, fileIndex, blob, loadingProgressCallback) ->
  options.uploadBegin.call(fileInput, filename, fileIndex, blob)
  settings = {
    method: "POST"
    cache: false
    contentType: false
    processData: false
    data: formDataResult
    xhr: ->
      xhr = new XMLHttpRequest
      xhr.upload.onprogress = loadingProgressCallback
      xhr
  }
  options.ajaxSettings.call(fileInput, settings, fileIndex, filename, blob)
  settings.url = options.url unless settings.url
  $.ajax(settings)


prettyJoin = (sequence, delimiter, lastDelimiter)->
  if sequence.length is 0
    return ""
  if sequence.length is 1
    return sequence[0]

  result = []
  for i in [0...sequence.length-2]
    result.push sequence[i]

  last = sequence[sequence.length-2] + lastDelimiter + sequence[sequence.length-1]
  return result.join(delimiter) + last



imageAction = (options, params, preview, file, blobCallback) ->
  convertTo = params.convertTo

  img = new Image
  canvas = document.createElement("canvas")

  img.onload = (e) ->
    if params.preview
      preview.append(canvas)
    w = this.width
    h = this.height

    if !convertTo
      canvas.width = w
      canvas.height = h
      canvas.getContext("2d").drawImage(this, 0, 0, w, h)
      blobCallback(file)
      return

    if convertTo.maxWidth or convertTo.maxHeight
      maxWidth = convertTo.maxWidth || this.width
      maxHeight = convertTo.maxHeight || this.height
      if typeof maxWidth is "string"
        maxWidth = Number(maxWidth)
      if typeof maxHeight is "string"
        maxHeight = Number(maxHeight)

      if w > maxWidth
        w = maxWidth
        h *= w / this.width
        if h > maxHeight
          h = maxHeight
          w = this.width * h / this.height
      else if h > maxHeight
        h = maxHeight
        w *= h / this.height
        if w > maxWidth
          w = maxWidth
          h = this.height * w / this.width
      if convertTo.width and convertTo.width < maxWidth
        w = convertTo.width
      if convertTo.height and convertTo.height < maxHeight
        h = convertTo.height
    else
      if convertTo.width
        w = convertTo.width
      if convertTo.height
        h = convertTo.height
    canvas.width = w
    canvas.height = h
    canvas.getContext("2d").drawImage(this, 0, 0, w, h)

    quality = convertTo.qualityArgument
    if (!quality or `quality == 1`) and
       w is this.width              and
       h is this.height             and
       file.type isnt convertTo.mimeType
      blobCallback(file)  # no need to resize or convert
      return
    quality = if quality is 1 then 1.1 else Number(quality)   # 1.1 - bug
    canvas.toBlob(blobCallback, convertTo.mimeType || file.type, quality)
  reader = new FileReader
  reader.onloadend = (e) ->
    img.src = e.target.result
  reader.readAsDataURL(file)




actions = $.fn.withDropZone.actions = {
  image: imageAction
  # more actions are gonna be here
}
