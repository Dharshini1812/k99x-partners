// lib/features/trial/presentation/widgets/trial_blocked_dialog.dart
//
// Shown instead of opening PlaceBidSheet whenever the current session
// is a trial/guest session (see TrialLogic.isTrialSession) — bidding is
// reserved for registered dealer accounts. One shared function so the
// copy/CTA can't drift between auction_card.dart and
// vehicle_detail_page.dart, the two places that open the bid sheet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';

Future<void> showTrialBlockedDialog(
  BuildContext context,
  WidgetRef ref, {
  required bool expired,
  String featureTitle = 'Bidding needs a registered account',
  String featureMessage =
      'You\'re exploring the app on a free trial. Sign up as a dealer to place bids and use autobid.',
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        expired ? Icons.timer_off_rounded : Icons.lock_clock_rounded,
        color: const Color(0xFF3F51E8),
        size: 40,
      ),
      title: Text(
        expired ? 'Your free trial has ended' : featureTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      content: Text(
        expired
            ? 'Your 48-hour free trial on this device is over. Sign up as a dealer to keep exploring auctions.'
            : featureMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563)),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Not now'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            ref.read(routeService).push(SignupRoute(), context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51E8),
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Sign up',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}
