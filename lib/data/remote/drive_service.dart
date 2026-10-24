import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      'email',
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<GoogleSignInAccount?> get currentUser async => _googleSignIn.currentUser;

  Future<drive.DriveApi> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('Not authenticated');
    return drive.DriveApi(client);
  }

  Future<void> uploadBackup(String jsonString) async {
    final api = await _getDriveApi();
    const fileName = 'subscriptions_backup.json';

    final fileList = await api.files.list(
      spaces: 'appDataFolder',
      q: "name='$fileName'",
    );

    final media = drive.Media(
      Stream.value(utf8.encode(jsonString)),
      utf8.encode(jsonString).length,
    );

    final driveFile = drive.File()..name = fileName;

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      final fileId = fileList.files!.first.id!;
      await api.files.update(driveFile, fileId, uploadMedia: media);
    } else {
      driveFile.parents = ['appDataFolder'];
      await api.files.create(driveFile, uploadMedia: media);
    }
  }

  Future<String?> downloadBackup() async {
    final api = await _getDriveApi();
    const fileName = 'subscriptions_backup.json';

    final fileList = await api.files.list(
      spaces: 'appDataFolder',
      q: "name='$fileName'",
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      return null;
    }

    final fileId = fileList.files!.first.id!;
    final drive.Media media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await media.stream.fold<List<int>>([], (previous, element) => previous..addAll(element));
    return utf8.decode(bytes);
  }
}
