part of nuxeo_client;

class AutomationUploaderEvent {
  String type;
  AutomationUploaderEvent(this.type);
}

// invoked when a new batch is started
// batchStarted

// invoked when the upload for given file has been started
// uploadStarted : function(fileIndex, file) {

// invoked when the upload for given file has been finished
//uploadFinished : function(fileIndex, file, time) {

// invoked when the progress for given file has changed
//fileUploadProgressUpdated : function(fileIndex, file, newProgress) {

// invoked when the upload speed of given file has changed
//fileUploadSpeedUpdated : function(fileIndex, file, KBperSecond) {

// invoked when all files have been uploaded
//batchFinished : function(batchId) {

class Upload {
  Completer _completer = new Completer();
  http.Blob file;
  int fileIndex;
  DateTime downloadStartTime;
  DateTime currentStart;
  int currentProgress;
  int startData;
  String batchId;
  Duration timeDiff;
  Upload(this.file);
  void complete() {
    var now = new DateTime.now();
    timeDiff = now.difference(downloadStartTime);
    _completer.complete(this);
   }
  Future<Upload> get future => _completer.future;
}

/**
 * [BatchUploader] manages the upload of files in a queue with a target
 * number of concurrent uploads.
 */
class BatchUploader {

  static final LOG = new Logger("nuxeo.automation.uploader");

  Client client;

  StreamController<AutomationUploaderEvent> evtController = new StreamController<AutomationUploaderEvent>();
  Stream<AutomationUploaderEvent> get onBatchStarted => evtController.stream.where((e) => e.type == "batchStarted");

  int numConcurrentUploads;

  // define if upload should be triggered directly
  bool directUpload;

  // update upload speed every second
  int uploadRateRefreshTime;

  Duration uploadTimeout;

  String batchId;
  bool _sendingRequestsInProgress = false;
  Queue<Upload> _uploadStack = new Queue();
  int uploadIdx = 0;
  int _nbUploadInprogress = 0;
  List _completedUploads = [];

  BatchUploader(this.client, {
    this.numConcurrentUploads : 5,
    // define if upload should be triggered directly
    this.directUpload : true,
    // update upload speed every second
    this.uploadRateRefreshTime : 1000,
    this.uploadTimeout
  }) {
  }

  Future initialize() {
    if (batchId != null) {
      return new Future.value(batchId);
    }
    return client.httpClient.post(Uri.parse("${client.restUri}/upload"))
    .send()
    .then((response) {
      var json = JSON.decode(response.body);
      if (json.isEmpty) {
        throw new Exception("Failed to initialize batch upload.");
      }
      if (batchId == null) {
        batchId = json["batchId"];
      }
      return batchId;
    });
  }

  Future<Upload> uploadFile(cfile) => initialize().then((_) {
    var entry = new Upload(cfile);
    _uploadStack.add(entry);
    if (directUpload && !_sendingRequestsInProgress && _uploadStack.isNotEmpty) {
      uploadFiles();
    }
    return entry.future;
  });

  uploadFiles() {

    if (_nbUploadInprogress >= numConcurrentUploads) {
      _sendingRequestsInProgress = false;
      LOG.info("delaying upload for next file(s) $uploadIdx"
            "+ since there are already $_nbUploadInprogress"
            " active uploads");
      return;
    }

    // this.opts.handler.batchStarted();
    _sendingRequestsInProgress = true;

    while (_uploadStack.isNotEmpty) {

      var upload = _uploadStack.removeFirst();
      upload.fileIndex = uploadIdx + 0;
      upload.downloadStartTime = new DateTime.now();
      upload.currentStart = upload.downloadStartTime;
      upload.currentProgress = 0;
      upload.startData = 0;
      upload.batchId = batchId;

      var file = upload.file;

      _nbUploadInprogress++;

      // compute timeout in seconds and integer
      int uploadTimeoutS = (uploadTimeout + new Duration(seconds: 5)).inSeconds;

      LOG.info("starting upload for file $uploadIdx");

      // create a new xhr object
      var xhr = client.httpClient.post(Uri.parse("${client.restUri}/upload/${batchId}/${uploadIdx}"));
      xhr.headers.set("Cache-Control", "no-cache");
      xhr.headers.set("X-Requested-With", "XMLHttpRequest");
      xhr.headers.set("X-File-Name", Uri.encodeComponent(file.filename));
      xhr.headers.set("X-File-Size", file.length.toString());
      xhr.headers.set("X-File-Type", file.mimetype);
      xhr.headers.set('Nuxeo-Transaction-Timeout', uploadTimeoutS.toString());

      uploadIdx++;

      xhr.send(file).then((response) {
        load(upload);
      });

      if (_nbUploadInprogress >= numConcurrentUploads) {
        _sendingRequestsInProgress = false;
        LOG.info("delaying upload for next file(s) $uploadIdx"
              "+ since there are already "
              "$_nbUploadInprogress active uploads");
        return;
      }
      _sendingRequestsInProgress = false;
    }

  }

  load(Upload upload) {
    var fileIdx = upload.fileIndex;
    LOG.info("Received loaded event on  file $fileIdx");
    if (!_completedUploads.contains(fileIdx)) {
      _completedUploads.add(fileIdx);
    } else {
      LOG.info("Event already processsed for file $fileIdx, exiting");
      return;
    }

    //this.opts.handler.uploadFinished(upload.fileIndex, upload.file,timeDiff);
    LOG.info("upload of file ${upload.fileIndex} completed");

    upload.complete();

    _nbUploadInprogress--;
    if (!_sendingRequestsInProgress && _uploadStack.isNotEmpty
        && _nbUploadInprogress < numConcurrentUploads) {
      // restart upload
      LOG.info("restart pending uploads");
      uploadFiles();
    } else if (_nbUploadInprogress == 0) {
      //this.opts.handler.batchFinished(this.batchId);
    }
  }

  info() => client.httpClient.get(Uri.parse("${client.restUri}/upload/$batchId"))
    .send()
    .then((response) {
      var json = JSON.decode(response.body);
      if (json.isEmpty) {
        throw new Exception("Batch $batchId does not exist.");
      }
      return json;
    });

  drop() => client.httpClient.delete(Uri.parse("${client.restUri}/upload/${batchId}")).send();

}