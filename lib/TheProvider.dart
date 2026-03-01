import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

extension ResponsiveContext on BuildContext{
  bool get isMobile => MediaQuery.of(this).size.width < 800;
  double get screenWidth => (((((MediaQuery.of(this).size.width-16)*12)/50)-103)/3);
}

class UserProvider extends ChangeNotifier {
  String? _firstName;
  String? _lastName;
  String? _studentId;
  String? _role;
  String? _bio;
  String? _institution;
  String? _phone;
  String? _country;
  String? _flag;
  String? _email;
  String? _dob;
  int? _age;
  Timestamp? _createdAt;
  bool _isLoading = false;

  String get firstName => _firstName ?? "";
  String get lastName => _lastName ?? "";
  String get id => _studentId ?? "";
  String get role => _role ?? "user";
  String get email => _email ?? "";
  String get bio => _bio ?? "";
  String get institution => _institution ?? "";
  String get phone => _phone ?? "";
  String get country => _country ?? "Unknown";
  String get flag => _flag ?? "🌍";
  String get dob => _dob ?? "(Select Date of Birth)";
  int get age => _age ?? 0;
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
        fetchUserData(user.uid);
      } else {
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
        _studentId = data['studentId'];
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
    required String fname, required String lname, required String bio, required String id, required String inst, required String phone, required String country,
    required String flag, required String dob, required int age,
  })
  async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try{
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstname' : fname,
        'lastname' : lname,
        'bio' : bio,
        'studentId' : id,
        'institution' : inst,
        'phone' : phone,
        'country' : country,
        'flag' : flag,
        'dob' : dob,
        'age' : age,
      });

      //update local state so UI updates without a refresh
      _firstName = fname; _lastName = lname; _bio = bio; _studentId = id; _institution = inst; _phone = phone; _country = country; _flag = flag; _dob = dob; _age = age;
      notifyListeners();
      return true;
    } catch(e){
      return false;
    }
  }
}


// profile: circle dp insert image, banner, liked sports
// tournament password, tournament id public, manage participants with groupwise, enter participant with string or team id(if have account)
//  