// Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/custom_widgets/default_container.dart';
import '../../constants/style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';


class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

var moreInfoOptions = const [
  [
    "App Version:",
    "0.1.0",
    null,
  ],
  [
    "Collaborators",
    "See the team behind this app",
    null,
  ],
  [
    "Privacy Policy",
    "Read more",
    null,
  ],
];

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0XFF7DA1C4),
          ),
          onPressed: () {
            Navigator.pop(context);
            // Return to previous page
          },
        ),
        title: Text(
          'Privacy Policy',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child:
          Padding(padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Sossoldi is build as an open source app. This service is provided by us at no cost and it is intended for use as is.\nThis page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.\nIf you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.\n',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'Information Collection and Use\n',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to System logs, Device manufacturer information. The information that I request will be retained on your device and is not collected by me in any way.\n',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'Log Data\n',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'I want to inform you that whenever you use our Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.\n',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'Service Providers\n',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'We may employ third-party companies and individuals due to the following reasons:\nTo facilitate our Service;\nTo provide the Service on our behalf;\nTo perform Service-related services; or\nTo assist us in analyzing how our Service is used.\nWe want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf.\n',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'Changes to This Privacy Policy\n',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page./This policy is effective as of 2023-01-11\n',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  'Contact us\n',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                RichText(
                  text: TextSpan(
                    text: 'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at ',
                    style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                    children: [
                      TextSpan(
                        text: 'help.sossoldi@gmail.com',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri(
                                scheme: 'mailto',
                                path: 'help.sossoldi@gmail.com',
                                queryParameters: {
                                    'subject': 'Request info',
                                },
                            ));
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ) 
      ),
    );
  }
}
