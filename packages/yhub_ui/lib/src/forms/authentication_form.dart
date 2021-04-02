import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yhub_ui/l10n/yhub_ui_localizations.dart';
import 'package:yhub_ui/l10n/yhub_ui_localizations_ar.dart';

class AuthenticationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> Function(bool isSignIn) fields;
  final List<Widget> Function(bool isSignIn)? children;

  final Widget logo;
  final Widget? slogan;

  final Function()? onForgot;
  final Function()? onAskTerms;
  final Function Function(bool isSignIn)? onChanged;
  final Future Function(bool isSignIn) onSubmit;

  const AuthenticationForm({
    Key? key,
    required this.formKey,
    required this.logo,
    this.slogan,
    required this.fields,
    this.onChanged,
    required this.onSubmit,
    this.onForgot,
    this.onAskTerms,
    this.children,
  }) : super(key: key);

  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  bool _isLoading = false;
  bool _isSignIn = true;
  bool _isAgree = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.logo,
          ),
          if (widget.slogan != null) widget.slogan!,
          const SizedBox(height: 16),
          ...widget.fields(_isSignIn),
          if (_isSignIn) ...[
            if (widget.onForgot != null)
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    style: Theme.of(context).textButtonTheme.style,
                    onPressed: widget.onForgot,
                    child: Text(
                      YHubUILocalizations.of(context)!.forgotPassword,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontSize: 14,
                          ),
                    ),
                  ),
                ],
              )
            else
              const SizedBox(height: 16.0),
          ] else ...[
            if (widget.onAskTerms != null) _buildTermsOfService(),
            const SizedBox(height: 16.0),
          ],
          ElevatedButton.icon(
            icon: _isLoading
                ? SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : SizedBox(),
            label: _isLoading
                ? SizedBox()
                : Text(
                    _isSignIn
                        ? YHubUILocalizations.of(context)!.signIn
                        : YHubUILocalizations.of(context)!.signUp,
                  ),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              minimumSize: Size(double.infinity, 48.0),
              shape: const StadiumBorder(),
            ),
            onPressed: _isLoading ? null : _submit,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            child: Text(
              _isSignIn
                  ? YHubUILocalizations.of(context)!.newHere
                  : YHubUILocalizations.of(context)!.alreadyRegistered,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.0),
              primary: Theme.of(context).backgroundColor,
              onPrimary: Theme.of(context).accentColor,
              shape: const StadiumBorder(),
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() {
                      widget.formKey.currentState!.reset();
                      widget.onChanged!(_isSignIn = !_isSignIn);
                    });
                  },
          ),
          if (widget.children != null) ...widget.children!(_isSignIn),
        ],
      ),
    );
  }

  Widget _buildTermsOfService() {
    return FormField<bool>(
      initialValue: false,
      validator: (value) {
        if (!value!)
          return YHubUILocalizations.of(context)!.errorAcceptTermsOfService;

        return null;
      },
      onSaved: (value) => _isAgree = value!,
      builder: (FormFieldState<bool> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              title: Wrap(
                children: [
                  Text.rich(
                    TextSpan(
                      text: YHubUILocalizations.of(context)!.accept,
                      style: Theme.of(context).textTheme.bodyText2,
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              ' ${YHubUILocalizations.of(context)!.termsOfService}',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onAskTerms,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
              value: state.value,
              onChanged: (_) => state.didChange(!state.value!),
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: Theme.of(state.context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.red),
              ),
          ],
        );
      },
    );
  }

  _submit() {
    if (widget.formKey.currentState!.validate()) {
      widget.formKey.currentState!.save();

      if (!_isSignIn) assert(_isAgree);

      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });

      widget.onSubmit(_isSignIn).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}
