import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jhatpat/models/user_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/error_widget.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool userProfileComplete = false;
  bool errorLoadingProfile = false;
  UserProfileData? userProfileData;
  bool _loading = true;
  bool _uploading = false;
  bool _uploadingImg = false;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    checkUserData().whenComplete(() => setState(() => _loading = false));
  }

  Future checkUserData() async {
    try {
      userProfileData =
          await DatabaseService(token: UserSharedPreferences.getUserToken())
              .getProfileDetails();

      if (userProfileData!.name == null) {
      } else {
        _nameController.text = userProfileData!.name!;
        _emailController.text = userProfileData!.email!;
        setState(() => userProfileComplete = true);
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
      setState(() => errorLoadingProfile = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: !_loading
          ? !errorLoadingProfile
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Form(
                    key: _globalKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            maxRadius: 50.0,
                            backgroundImage: userProfileComplete
                                ? userProfileData!.image!.isNotEmpty
                                    ? Image.network(
                                        "https://dev.jhatpat.app/storage/images/users/" +
                                            userProfileData!.image!,
                                        frameBuilder: (context, child, frame,
                                                wasSynchronouslyLoaded) =>
                                            frame != null
                                                ? child
                                                : const Loading(white: false),
                                        loadingBuilder: (context, child,
                                                loadingProgress) =>
                                            loadingProgress != null
                                                ? child
                                                : const Loading(white: false),
                                      ).image
                                    : Image.asset(
                                            "assets/images/UserProfileDefault.png")
                                        .image
                                : Image.asset(
                                        "assets/images/UserProfileDefault.png")
                                    .image,
                          ),
                          const SizedBox(height: 10.0, width: 0.0),
                          blackMaterialButtons(
                            () async {
                              setState(() => _uploadingImg = true);
                              try {
                                _image = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 40);
                                if (_image != null) {
                                  await DatabaseService(
                                          token: UserSharedPreferences
                                              .getUserToken()!)
                                      .postUserImage("data:image/png;base64," +
                                          base64Encode(
                                              await _image!.readAsBytes()))
                                      .then((value) {
                                    if (value) {
                                      setState(() => _loading = true);
                                      checkUserData().whenComplete(() =>
                                          setState(() => _loading = false));
                                    } else {
                                      null;
                                    }
                                  });
                                } else {
                                  null;
                                }
                              } catch (e) {
                                commonSnackbar(e.toString(), context);
                              }
                              setState(() => _uploadingImg = false);
                            },
                            !_uploadingImg
                                ? const Text(
                                    "Upload Image",
                                    style: TextStyle(fontSize: 16.0),
                                  )
                                : const Loading(white: true),
                          ),
                          const SizedBox(height: 10.0, width: 0.0),
                          Card(
                            elevation: 6.0,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: authTextInputDecoration(
                                  "Name", Icons.person, null),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              focusNode: _nameFocus,
                              validator: (val) => val != null
                                  ? nameValidator(val)
                                  : "Please add a name",
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (val) => FocusScope.of(context)
                                  .requestFocus(_emailFocus),
                            ),
                          ),
                          const SizedBox(height: 10.0, width: 0.0),
                          Card(
                            elevation: 6.0,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: authTextInputDecoration(
                                  "Email", Icons.mail, null),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              focusNode: _emailFocus,
                              validator: (val) => val != null
                                  ? emailValidator(val)
                                  : "Please add an email",
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (val) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                          const SizedBox(height: 20.0, width: 0.0),
                          Consumer(
                            builder: (context, ref, __) {
                              return MaterialButton(
                                onPressed: () => updateButton(context, ref),
                                child: !_uploading
                                    ? const Text("Update",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                    : const Loading(white: true),
                                minWidth: double.infinity,
                                elevation: 0.0,
                                focusElevation: 0.0,
                                highlightElevation: 0.0,
                                color: Colors.black,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : errorWidget(Icons.error,
                  "Could not load profile,\nPlease try again after logging out")
          : const Center(
              child: Loading(white: false, rad: 14.0),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void updateButton(BuildContext context, WidgetRef ref) async {
    if (_globalKey.currentState!.validate()) {
      setState(() => _uploading = true);

      try {
        final bool result =
            await DatabaseService(token: UserSharedPreferences.getUserToken()!)
                .postUserDetails(
          UserProfileData(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
          ),
        );
        setState(() => _uploading = false);
        if (result) {
          commonSnackbar("Profile updated successfully", context);
          ref.read(profileUpdated.state).state = true;
        } else {
          commonSnackbar("Something went wrong, please try again", context);
        }
      } catch (e) {
        commonSnackbar(e.toString(), context);
        setState(() => _uploading = false);
      }
    }
  }

  String? nameValidator(String val) {
    if (val.isEmpty) {
      return "Please add a name";
    } else {
      if (val.length < 3 || val.length > 20) {
        return "Name can't be less than 3 or more than 20 letters";
      } else {
        if (val.contains(RegExp(r"^[a-zA-Z ]+$"))) {
          return null;
        } else {
          return "Enter a proper name";
        }
      }
    }
  }

  String? emailValidator(String val) {
    const String emailReg =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    if (val.isEmpty) {
      return "Please add an email";
    } else {
      if (RegExp(emailReg.toString(), caseSensitive: false).hasMatch(val)) {
        return null;
      } else {
        return "Please enter a proper email address";
      }
    }
  }
}
