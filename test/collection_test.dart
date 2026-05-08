import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:social_hub/services/auth_service.dart';

void main() async {

  // ADDED THIS
  TestWidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCmYXbvMg_lZzVpSCqPsP8JR34iFUXPBUA',
      appId: '1:165073928557:android:f3d38d31d525e915285a64', 
      messagingSenderId: '165073928557', 
      projectId: 'social-hub-7bdc6',
    ),
  );

  test('Get Firestore field', () async {

    String? result =
        await AuthService()
            .getFieldOfCollectionFromPath(
              'users/admin',
              'fullName',
            );

    print(result);

    expect(result, isNotNull);
  });
}