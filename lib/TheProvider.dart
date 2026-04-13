import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

extension ResponsiveContext on BuildContext{
  bool get isMobile => MediaQuery.of(this).size.width < 800;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get boxWidth => (((((MediaQuery.of(this).size.width-16)*12)/50)-103)/3);
}

class UserProvider extends ChangeNotifier {
  String? _uid;
  String? _firstName;
  String? _lastName;
  String? _role;
  String? _bio;
  String? _institution;
  String? _phone;
  String? _country;
  String? _flag;
  String? _email;
  String? _dob;
  int? _age;
  String? _dpUrl;
  Timestamp? _createdAt;
  bool _isLoading = false;

  bool get isLoggedIn => _uid != null;
  String get uid => _uid ?? "";
  String get firstName => _firstName ?? "";
  String get lastName => _lastName ?? "";
  String get role => _role ?? "user";
  String get email => _email ?? "";
  String get bio => _bio ?? "";
  String get institution => _institution ?? "";
  String get phone => _phone ?? "";
  String get country => _country ?? "Unknown";
  String get flag => _flag ?? "🌍";
  String get dob => _dob ?? "(Select Date of Birth)";
  int get age => _age ?? 0;
  String? get dpUrl => _dpUrl;
  bool get isLoading => _isLoading;
  
  String get joinedDate{
    if(_createdAt == null) return "N/A";
    DateTime date = _createdAt!.toDate();
    return DateFormat('d MMMM, y').format(date);
  }

  String get initial {
    if (_firstName != null && _firstName!.isNotEmpty) {
      return _firstName![0].toUpperCase();
    }
    return "?";
  }

  UserProvider() {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _uid = user.uid;
        fetchUserData(user.uid);
      } else {
        _uid = null;
        _firstName = null;
        _role = null;
        notifyListeners();
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    _isLoading = true;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        _firstName = data['firstname'];
        _lastName = data['lastname'];
        _role = data['role'];
        _email = data['email'];
        _createdAt = data['createAt'];
        _bio = data['bio'];
        _country = data['country'];
        _phone = data['phone'];
        _institution = data['institution'];
        _flag = data['flag'];
        _dob = data['dob'];
        _age = data['age'];
        _dpUrl = data['logo_url'];
        
        print("Provider successfully fetched: $_firstName");
      } else {
        print("No firestore document found for UID: $uid");
      }
    } catch (e) {
      print("Error in Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // editing updates
  Future<bool> updateProfile({
    required String fname, required String lname, required String bio, required String inst, required String phone, required String country,
    required String flag, required String dob, required int age, required String? dpUrl,
  })
  async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try{
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstname' : fname,
        'lastname' : lname,
        'bio' : bio,
        'institution' : inst,
        'phone' : phone,
        'country' : country,
        'flag' : flag,
        'dob' : dob,
        'age' : age,
        'logo_url': dpUrl,
      });

      //update local state so UI updates without refresh
      _firstName = fname; _lastName = lname; _bio = bio; _institution = inst; _phone = phone; _country = country; _flag = flag; _dob = dob; _age = age; _dpUrl = dpUrl;
      notifyListeners();
      return true;
    } catch(e){
      return false;
    }
  }
}


// profile: banner
// AI integrate, knockout bracket
// ParticipantTab fix for knockout only, notification/announcement, interested button
// showcase, Admin permission, squad add permission
// add enter link/upload system in participantsTab/tournament Logo