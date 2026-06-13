import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_kab.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('kab')
  ];

  /// No description provided for @allOperators.
  ///
  /// In en, this message translates to:
  /// **'All Operators'**
  String get allOperators;

  /// No description provided for @recentRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent Requests'**
  String get recentRequests;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @decisionNotes.
  ///
  /// In en, this message translates to:
  /// **'Decision Notes / Reason'**
  String get decisionNotes;

  /// No description provided for @enterDecisionReason.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for decision or modification...'**
  String get enterDecisionReason;

  /// No description provided for @statusUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Status updated successfully'**
  String get statusUpdateSuccess;

  /// No description provided for @statusUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating status'**
  String get statusUpdateError;

  /// No description provided for @latestActivitiesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Latest Activities'**
  String get latestActivitiesAdmin;

  /// No description provided for @adminReadOnlyView.
  ///
  /// In en, this message translates to:
  /// **'Admin View: Read-only'**
  String get adminReadOnlyView;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusModReq.
  ///
  /// In en, this message translates to:
  /// **'Mod. Req'**
  String get statusModReq;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterCode;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm Email'**
  String get confirmEmail;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a code to'**
  String get codeSentTo;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to receive important notifications.'**
  String get enterEmailHint;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// No description provided for @clientPortal.
  ///
  /// In en, this message translates to:
  /// **'Client Portal'**
  String get clientPortal;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @operatorPortalSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Institutional Mediator for {company}'**
  String operatorPortalSubTitle(String company);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tameeni Elite'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tameeni Elite'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @policies.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policies;

  /// No description provided for @surplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus Distribution'**
  String get surplus;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal Hub'**
  String get legal;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @activePolicies.
  ///
  /// In en, this message translates to:
  /// **'Active Policies'**
  String get activePolicies;

  /// No description provided for @totalPremium.
  ///
  /// In en, this message translates to:
  /// **'Total Premium'**
  String get totalPremium;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Platform Commission'**
  String get commission;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @rejectedRequests.
  ///
  /// In en, this message translates to:
  /// **'Rejected Requests'**
  String get rejectedRequests;

  /// No description provided for @allRequests.
  ///
  /// In en, this message translates to:
  /// **'All Requests'**
  String get allRequests;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Request Modification'**
  String get modify;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Insurance Plans'**
  String get plans;

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare Plans'**
  String get comparePlans;

  /// No description provided for @commissionMonitor.
  ///
  /// In en, this message translates to:
  /// **'Commission Monitor — 4%'**
  String get commissionMonitor;

  /// No description provided for @totalPremiumsCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Premiums Collected'**
  String get totalPremiumsCollected;

  /// No description provided for @commissionTaminyElite.
  ///
  /// In en, this message translates to:
  /// **'Tameeni Elite Commission (4%)'**
  String get commissionTaminyElite;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Count'**
  String get transactionCount;

  /// No description provided for @commissionRuleNote.
  ///
  /// In en, this message translates to:
  /// **'Commission: 4% fixed — programmed at Edge Function level (Supabase)'**
  String get commissionRuleNote;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @policyNumber.
  ///
  /// In en, this message translates to:
  /// **'Policy Number'**
  String get policyNumber;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @commission4Percent.
  ///
  /// In en, this message translates to:
  /// **'Commission 4%'**
  String get commission4Percent;

  /// No description provided for @netFund.
  ///
  /// In en, this message translates to:
  /// **'Net Fund'**
  String get netFund;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @shariaInsurance.
  ///
  /// In en, this message translates to:
  /// **'Sharia Insurance'**
  String get shariaInsurance;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Elite Support'**
  String get supportHeaderTitle;

  /// No description provided for @supportHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dedicated assistance for our elite participants. Our specialized mediators are available to ensure your experience remains seamless.'**
  String get supportHeaderSubtitle;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @priorityCall.
  ///
  /// In en, this message translates to:
  /// **'Priority Call'**
  String get priorityCall;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @frequentQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequent Questions'**
  String get frequentQuestions;

  /// No description provided for @legalComplianceHub.
  ///
  /// In en, this message translates to:
  /// **'Legal & Compliance Hub'**
  String get legalComplianceHub;

  /// No description provided for @legalHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive overview of our mediation framework, regulatory adherence, and the principles of Sovereign Trust guiding our operations under Decree 21-81.'**
  String get legalHeaderSubtitle;

  /// No description provided for @downloadDossier.
  ///
  /// In en, this message translates to:
  /// **'Download Dossier'**
  String get downloadDossier;

  /// No description provided for @mediationMandate.
  ///
  /// In en, this message translates to:
  /// **'The Mediation Mandate'**
  String get mediationMandate;

  /// No description provided for @electronicPayment.
  ///
  /// In en, this message translates to:
  /// **'Electronic Payment'**
  String get electronicPayment;

  /// No description provided for @paymentLocked.
  ///
  /// In en, this message translates to:
  /// **'Payment Locked — Awaiting Company Approval'**
  String get paymentLocked;

  /// No description provided for @paymentUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Approved — You can proceed to payment'**
  String get paymentUnlocked;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @policyType.
  ///
  /// In en, this message translates to:
  /// **'Policy Type'**
  String get policyType;

  /// No description provided for @coverageDuration.
  ///
  /// In en, this message translates to:
  /// **'Coverage Duration'**
  String get coverageDuration;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment Breakdown'**
  String get paymentBreakdown;

  /// No description provided for @tabarruPremium.
  ///
  /// In en, this message translates to:
  /// **'Tabarru\' (Participants Fund)'**
  String get tabarruPremium;

  /// No description provided for @platformCommission.
  ///
  /// In en, this message translates to:
  /// **'Platform commission (4.5% from client)'**
  String get platformCommission;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolder;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get amountToPay;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred payment method to complete the transaction.'**
  String get choosePaymentMethod;

  /// No description provided for @edahabiaCard.
  ///
  /// In en, this message translates to:
  /// **'Edahabia Card'**
  String get edahabiaCard;

  /// No description provided for @securePaymentNotice.
  ///
  /// In en, this message translates to:
  /// **'Your payment is secured with high-grade encryption.'**
  String get securePaymentNotice;

  /// No description provided for @sovereignTrustVerified.
  ///
  /// In en, this message translates to:
  /// **'Sovereign Trust Verified'**
  String get sovereignTrustVerified;

  /// No description provided for @decreeComplianceFootnote.
  ///
  /// In en, this message translates to:
  /// **'Includes 4% platform commission according to Decree 21-81'**
  String get decreeComplianceFootnote;

  /// No description provided for @uploadDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please upload the required documents to complete your registration'**
  String get uploadDocumentsSubtitle;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @uploadNationalIdHint.
  ///
  /// In en, this message translates to:
  /// **'Upload your national identity card'**
  String get uploadNationalIdHint;

  /// No description provided for @proofOfAddress.
  ///
  /// In en, this message translates to:
  /// **'Proof of Address'**
  String get proofOfAddress;

  /// No description provided for @uploadProofOfAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a proof of address document'**
  String get uploadProofOfAddressHint;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @passwordSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password to secure your account'**
  String get passwordSetupSubtitle;

  /// No description provided for @welcomeClient.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeClient(String name);

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @noCurrentRequests.
  ///
  /// In en, this message translates to:
  /// **'No current requests'**
  String get noCurrentRequests;

  /// No description provided for @yourRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Your request status'**
  String get yourRequestStatus;

  /// No description provided for @requestNumber.
  ///
  /// In en, this message translates to:
  /// **'Request number: '**
  String get requestNumber;

  /// No description provided for @viewRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'View request details'**
  String get viewRequestDetails;

  /// No description provided for @financialSurplusReturn.
  ///
  /// In en, this message translates to:
  /// **'Financial surplus (Return)'**
  String get financialSurplusReturn;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @documentsUploaded.
  ///
  /// In en, this message translates to:
  /// **'Documents uploaded'**
  String get documentsUploaded;

  /// No description provided for @requestUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Request under review'**
  String get requestUnderReview;

  /// No description provided for @homeNav.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNav;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get requestId;

  /// No description provided for @insuranceInfo.
  ///
  /// In en, this message translates to:
  /// **'Insurance Information'**
  String get insuranceInfo;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents uploaded'**
  String get noDocuments;

  /// No description provided for @insurancePlan.
  ///
  /// In en, this message translates to:
  /// **'Insurance Plan'**
  String get insurancePlan;

  /// No description provided for @plansNav.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansNav;

  /// No description provided for @employeePortal.
  ///
  /// In en, this message translates to:
  /// **'Employee Portal'**
  String get employeePortal;

  /// No description provided for @algeriaTakaful.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful - Takaful Insurance'**
  String get algeriaTakaful;

  /// No description provided for @alIttihad.
  ///
  /// In en, this message translates to:
  /// **'Al Ittihad'**
  String get alIttihad;

  /// No description provided for @fundsSeparateNotice.
  ///
  /// In en, this message translates to:
  /// **'These funds are completely separate from shareholders\' funds according to Executive Decree 21-81'**
  String get fundsSeparateNotice;

  /// No description provided for @totalSurplus.
  ///
  /// In en, this message translates to:
  /// **'Total surplus'**
  String get totalSurplus;

  /// No description provided for @policyholdersSurplusLegend.
  ///
  /// In en, this message translates to:
  /// **'Policyholders\' Fund (Cooperative Surplus)'**
  String get policyholdersSurplusLegend;

  /// No description provided for @shareholdersManagementFeeLegend.
  ///
  /// In en, this message translates to:
  /// **'Shareholders\' Fund (Management Fees)'**
  String get shareholdersManagementFeeLegend;

  /// No description provided for @beneficiaryCount.
  ///
  /// In en, this message translates to:
  /// **'Number of beneficiaries'**
  String get beneficiaryCount;

  /// No description provided for @distributionLog.
  ///
  /// In en, this message translates to:
  /// **'Distributions log'**
  String get distributionLog;

  /// No description provided for @addDistribution.
  ///
  /// In en, this message translates to:
  /// **'Add distribution'**
  String get addDistribution;

  /// No description provided for @noDistributionsYet.
  ///
  /// In en, this message translates to:
  /// **'No distributions yet'**
  String get noDistributionsYet;

  /// No description provided for @pendingState.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingState;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @addSurplusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Add surplus distribution'**
  String get addSurplusDistribution;

  /// No description provided for @subscriberName.
  ///
  /// In en, this message translates to:
  /// **'Subscriber name'**
  String get subscriberName;

  /// No description provided for @ccpNumber.
  ///
  /// In en, this message translates to:
  /// **'CCP number'**
  String get ccpNumber;

  /// No description provided for @amountDzd.
  ///
  /// In en, this message translates to:
  /// **'{amount} DZD'**
  String amountDzd(String amount);

  /// No description provided for @systemOperational.
  ///
  /// In en, this message translates to:
  /// **'System operational'**
  String get systemOperational;

  /// No description provided for @fundSeparation.
  ///
  /// In en, this message translates to:
  /// **'Fund separation'**
  String get fundSeparation;

  /// No description provided for @decree2181.
  ///
  /// In en, this message translates to:
  /// **'Decree 21-81'**
  String get decree2181;

  /// No description provided for @subscribersFunds.
  ///
  /// In en, this message translates to:
  /// **'Subscribers\' funds'**
  String get subscribersFunds;

  /// No description provided for @platformCommissionPct.
  ///
  /// In en, this message translates to:
  /// **'Platform commission (4%)'**
  String get platformCommissionPct;

  /// No description provided for @latestAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'Latest audit log entries'**
  String get latestAuditLogs;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @splashKeywords.
  ///
  /// In en, this message translates to:
  /// **'Trusted Insurance · Smart & Simple · Algeria'**
  String get splashKeywords;

  /// No description provided for @selectAccountTypeToProceed.
  ///
  /// In en, this message translates to:
  /// **'Select your account type to proceed'**
  String get selectAccountTypeToProceed;

  /// No description provided for @clientRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply for Takaful policies'**
  String get clientRoleSubtitle;

  /// No description provided for @operatorRole.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operatorRole;

  /// No description provided for @operatorRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful or Al-Ittihad'**
  String get operatorRoleSubtitle;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'System Admin'**
  String get adminRole;

  /// No description provided for @adminRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three-factor portal'**
  String get adminRoleSubtitle;

  /// No description provided for @footerText.
  ///
  /// In en, this message translates to:
  /// **'Tameeni Elite — Digital Takaful Platform\nCompliant with Decree 21-81'**
  String get footerText;

  /// No description provided for @operatorPortal.
  ///
  /// In en, this message translates to:
  /// **'Operator Portal'**
  String get operatorPortal;

  /// No description provided for @chooseCompanyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose your company then login or create an account'**
  String get chooseCompanyPrompt;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAction;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginAction;

  /// No description provided for @adminPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Tameeni Elite'**
  String get adminPortalTitle;

  /// No description provided for @adminPortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted Digital Takaful Platform\nCompliant with Decree 21-81'**
  String get adminPortalSubtitle;

  /// No description provided for @activeAudited.
  ///
  /// In en, this message translates to:
  /// **'Active / Audited'**
  String get activeAudited;

  /// No description provided for @generalManager.
  ///
  /// In en, this message translates to:
  /// **'General Manager'**
  String get generalManager;

  /// No description provided for @adminLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter credentials to access the dashboard'**
  String get adminLoginPrompt;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Password'**
  String get adminPasswordLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @credentialError.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get credentialError;

  /// No description provided for @notAdminError.
  ///
  /// In en, this message translates to:
  /// **'This account is not an administrator account.'**
  String get notAdminError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @biometricVerification.
  ///
  /// In en, this message translates to:
  /// **'Biometric Verification'**
  String get biometricVerification;

  /// No description provided for @biometricStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 2/3 — Fingerprint or Face'**
  String get biometricStepSubtitle;

  /// No description provided for @verifyIdentityPrompt.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to enter'**
  String get verifyIdentityPrompt;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @verifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verified ✓'**
  String get verifiedSuccess;

  /// No description provided for @pressToScan.
  ///
  /// In en, this message translates to:
  /// **'Press to Scan Biometric'**
  String get pressToScan;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @otpStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 3/3 — One-Time Password'**
  String get otpStepSubtitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get otpSentTo;

  /// No description provided for @enterFullCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full code'**
  String get enterFullCode;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get invalidOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendOtp;

  /// No description provided for @resendFailed.
  ///
  /// In en, this message translates to:
  /// **'Resend failed. Try again.'**
  String get resendFailed;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength: {strength}'**
  String passwordStrength(String strength);

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @pickFileError.
  ///
  /// In en, this message translates to:
  /// **'Error picking file'**
  String get pickFileError;

  /// No description provided for @uploadFileError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading file'**
  String get uploadFileError;

  /// No description provided for @choosePlanFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan first'**
  String get choosePlanFirst;

  /// No description provided for @selectedPlan.
  ///
  /// In en, this message translates to:
  /// **'Selected: {plan}'**
  String selectedPlan(String plan);

  /// No description provided for @coverageAmount.
  ///
  /// In en, this message translates to:
  /// **'Coverage Amount'**
  String get coverageAmount;

  /// No description provided for @annualPremium.
  ///
  /// In en, this message translates to:
  /// **'Annual Premium'**
  String get annualPremium;

  /// No description provided for @donationRatio.
  ///
  /// In en, this message translates to:
  /// **'Donation Ratio'**
  String get donationRatio;

  /// No description provided for @surplusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Surplus Distribution'**
  String get surplusDistribution;

  /// No description provided for @claimsProcessing.
  ///
  /// In en, this message translates to:
  /// **'Claims Processing'**
  String get claimsProcessing;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select this plan'**
  String get selectPlan;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// No description provided for @shariaApprovedNotice.
  ///
  /// In en, this message translates to:
  /// **'All plans provided are approved by the Sharia Supervisory Board. Algeria Takaful is committed to the highest standards of transparency in managing the donation fund and distributing the surplus.'**
  String get shariaApprovedNotice;

  /// No description provided for @comparePlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that suits your institutional needs and Sharia commitment.'**
  String get comparePlansSubtitle;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @dzd.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get dzd;

  /// No description provided for @decreeComplianceNotice.
  ///
  /// In en, this message translates to:
  /// **'All plans are compliant with Executive Decree 21-81 and Sharia Takaful principles'**
  String get decreeComplianceNotice;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available currently'**
  String get noPlansAvailable;

  /// No description provided for @tabarruRate.
  ///
  /// In en, this message translates to:
  /// **'Tabarru\' Rate'**
  String get tabarruRate;

  /// No description provided for @claimsDuration.
  ///
  /// In en, this message translates to:
  /// **'Claims Settlement Duration'**
  String get claimsDuration;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} DZD via {method}'**
  String paymentSuccessSubtitle(String amount, String method);

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @unauthenticatedError.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get unauthenticatedError;

  /// No description provided for @paymentFailedError.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailedError;

  /// No description provided for @paymentErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Payment Error: '**
  String get paymentErrorPrefix;

  /// No description provided for @ticketSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Ticket submitted successfully. An Elite Mediator will contact you shortly.'**
  String get ticketSuccessMessage;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How are financial surpluses distributed?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'Surpluses are distributed according to Takaful principles as outlined in Decree 21-81, ensuring absolute fairness among participants.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'Can I modify my policy coverage?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, elite participants can request modifications through their dashboard, subject to review by our specialist mediators.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'What is the role of the mediator?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'The mediator ensures ethical alignment between the participant and the operator, guarding the Sharia-compliant framework.'**
  String get faq3Answer;

  /// No description provided for @mediationMandateContent.
  ///
  /// In en, this message translates to:
  /// **'As an elite financial mediator, Tameeni Elite operates within a strictly defined perimeter designed to ensure absolute impartiality and ethical transparency. We do not hold client funds; rather, we orchestrate the secure alignment of Takaful principles between participants and operators.'**
  String get mediationMandateContent;

  /// No description provided for @decreeFrameworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Decree 21-81'**
  String get decreeFrameworkTitle;

  /// No description provided for @decreeFrameworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Full compliance with the foundational legal framework governing high-net-worth mediation and Islamic financial orchestration.'**
  String get decreeFrameworkDescription;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusLabel;

  /// No description provided for @lastReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'LAST REVIEW'**
  String get lastReviewLabel;

  /// No description provided for @statusModificationRequested.
  ///
  /// In en, this message translates to:
  /// **'Modification Required'**
  String get statusModificationRequested;

  /// No description provided for @policyHistory.
  ///
  /// In en, this message translates to:
  /// **'Policy History'**
  String get policyHistory;

  /// No description provided for @noPoliciesFound.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any policy requests yet.'**
  String get noPoliciesFound;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceipt;

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date}'**
  String submittedOn(String date);

  /// No description provided for @newRequests.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get newRequests;

  /// No description provided for @processingRequests.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processingRequests;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get completedToday;

  /// No description provided for @applicationNumber.
  ///
  /// In en, this message translates to:
  /// **'Application #{id}'**
  String applicationNumber(String id);

  /// No description provided for @subscriberInfo.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Information'**
  String get subscriberInfo;

  /// No description provided for @accountIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Account ID: {id}'**
  String accountIdentifier(String id);

  /// No description provided for @requestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get requestedAmount;

  /// No description provided for @applicationDate.
  ///
  /// In en, this message translates to:
  /// **'Application Date'**
  String get applicationDate;

  /// No description provided for @uploadedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Documents'**
  String get uploadedDocuments;

  /// No description provided for @lastUpdateDate.
  ///
  /// In en, this message translates to:
  /// **'Last Update: {date}'**
  String lastUpdateDate(String date);

  /// No description provided for @reviewDecision.
  ///
  /// In en, this message translates to:
  /// **'Review Decision'**
  String get reviewDecision;

  /// No description provided for @decisionTaken.
  ///
  /// In en, this message translates to:
  /// **'A decision has already been taken for this application.'**
  String get decisionTaken;

  /// No description provided for @viewAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined Date'**
  String get joinedDate;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @adminRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRoleLabel;

  /// No description provided for @operatorRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operatorRoleLabel;

  /// No description provided for @clientRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientRoleLabel;

  /// No description provided for @policyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your elite Takaful requests and policy documentation.'**
  String get policyHistorySubtitle;

  /// No description provided for @fullAuditTrail.
  ///
  /// In en, this message translates to:
  /// **'Full Audit Trail'**
  String get fullAuditTrail;

  /// No description provided for @noLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No audit logs found'**
  String get noLogsFound;

  /// No description provided for @supportSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Policy clarification'**
  String get supportSubjectHint;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your inquiry in detail...'**
  String get supportMessageHint;

  /// No description provided for @enterDashboard.
  ///
  /// In en, this message translates to:
  /// **'Enter Dashboard'**
  String get enterDashboard;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @unexpectedAuthError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedAuthError;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your Takaful account'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+213 6XX XXX XXX'**
  String get phoneHint;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhone;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendingOtp;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP Code'**
  String get sendOtp;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get enterName;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameTooShort;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @enterCCP.
  ///
  /// In en, this message translates to:
  /// **'Please enter your CCP account number'**
  String get enterCCP;

  /// No description provided for @ccpTooShort.
  ///
  /// In en, this message translates to:
  /// **'CCP number must be at least 10 digits'**
  String get ccpTooShort;

  /// No description provided for @ccpLabel.
  ///
  /// In en, this message translates to:
  /// **'CCP Account Number'**
  String get ccpLabel;

  /// No description provided for @ccpHint.
  ///
  /// In en, this message translates to:
  /// **'00XXXXXXXX'**
  String get ccpHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedUpper.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordNeedUpper;

  /// No description provided for @passwordNeedNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNeedNumber;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @accountCreateError.
  ///
  /// In en, this message translates to:
  /// **'Account creation failed. Please try again.'**
  String get accountCreateError;

  /// No description provided for @createPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPasswordTitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @clientPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Client Portal'**
  String get clientPortalTitle;

  /// No description provided for @existingAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I have an existing account'**
  String get existingAccountSubtitle;

  /// No description provided for @firstTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First time using Tameeni Elite'**
  String get firstTimeSubtitle;

  /// No description provided for @decree2181Compliance.
  ///
  /// In en, this message translates to:
  /// **'Compliant with Decree 21-81'**
  String get decree2181Compliance;

  /// No description provided for @useEmail.
  ///
  /// In en, this message translates to:
  /// **'Use Email instead'**
  String get useEmail;

  /// No description provided for @usePhone.
  ///
  /// In en, this message translates to:
  /// **'Use Phone instead'**
  String get usePhone;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get wrongPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get userNotFound;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get loginWithEmail;

  /// No description provided for @loginWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Login with Phone'**
  String get loginWithPhone;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your personal information correctly'**
  String get personalInfoSubtitle;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendAfter.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendAfter(String time);

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidCode;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired'**
  String get codeExpired;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get accountDisabled;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password for your account.'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @redirectingToHome.
  ///
  /// In en, this message translates to:
  /// **'Redirecting you to the home screen...'**
  String get redirectingToHome;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @registerNewEmployee.
  ///
  /// In en, this message translates to:
  /// **'Register New Employee'**
  String get registerNewEmployee;

  /// No description provided for @chooseTakafulCompany.
  ///
  /// In en, this message translates to:
  /// **'Choose Takaful Company'**
  String get chooseTakafulCompany;

  /// No description provided for @professionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get professionalInfo;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeIdLabel;

  /// No description provided for @employeeIdHint.
  ///
  /// In en, this message translates to:
  /// **'EMP-XXXXXX'**
  String get employeeIdHint;

  /// No description provided for @professionalEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Professional Email'**
  String get professionalEmailLabel;

  /// No description provided for @professionalEmailHint.
  ///
  /// In en, this message translates to:
  /// **'employee@company.dz'**
  String get professionalEmailHint;

  /// No description provided for @selectCompanyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a Takaful company first'**
  String get selectCompanyFirst;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @confirmationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A confirmation link has been sent to your email.\nAfter confirmation, you can log in to the {company} portal.'**
  String confirmationEmailSent(String company);

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @employeeIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Employee ID is required'**
  String get employeeIdRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @algeriaTakafulPortal.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful Portal'**
  String get algeriaTakafulPortal;

  /// No description provided for @alIttihadPortal.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Portal'**
  String get alIttihadPortal;

  /// No description provided for @employeePortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Portal'**
  String get employeePortalSubtitle;

  /// No description provided for @loginToSystemPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please log in to access the system'**
  String get loginToSystemPrompt;

  /// No description provided for @createEmployeeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Employee Account'**
  String get createEmployeeAccount;

  /// No description provided for @newEmployeeQuestion.
  ///
  /// In en, this message translates to:
  /// **'New employee?'**
  String get newEmployeeQuestion;

  /// No description provided for @exclusivePortalNote.
  ///
  /// In en, this message translates to:
  /// **'This portal is exclusively for {company} employees and its data is completely isolated.'**
  String exclusivePortalNote(String company);

  /// No description provided for @wrongCompanyError.
  ///
  /// In en, this message translates to:
  /// **'This account is not associated with {company}.'**
  String wrongCompanyError(String company);

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmailError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get passwordTooShortError;

  /// No description provided for @wilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get wilaya;

  /// No description provided for @selectWilaya.
  ///
  /// In en, this message translates to:
  /// **'Select Wilaya'**
  String get selectWilaya;

  /// No description provided for @ninLabel.
  ///
  /// In en, this message translates to:
  /// **'National Identity Number (NIN)'**
  String get ninLabel;

  /// No description provided for @ninHint.
  ///
  /// In en, this message translates to:
  /// **'0000 0000 0000 0000'**
  String get ninHint;

  /// No description provided for @dobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dobLabel;

  /// No description provided for @dobHint.
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get dobHint;

  /// No description provided for @enterCvv.
  ///
  /// In en, this message translates to:
  /// **'Please enter CVV'**
  String get enterCvv;

  /// No description provided for @invalidCvv.
  ///
  /// In en, this message translates to:
  /// **'Invalid CVV'**
  String get invalidCvv;

  /// No description provided for @enterExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter expiry date'**
  String get enterExpiryDate;

  /// No description provided for @invalidExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid expiry date (MM/YY)'**
  String get invalidExpiryDate;

  /// No description provided for @enterCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter card number'**
  String get enterCardNumber;

  /// No description provided for @invalidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid card number'**
  String get invalidCardNumber;

  /// No description provided for @enterCardHolder.
  ///
  /// In en, this message translates to:
  /// **'Please enter card holder name'**
  String get enterCardHolder;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOtpCode;

  /// No description provided for @otpSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code has been sent to\n{phone}'**
  String otpSentSubtitle(String phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @skipForDemo.
  ///
  /// In en, this message translates to:
  /// **'Skip Verification (For Demo Only)'**
  String get skipForDemo;

  /// No description provided for @totalSurplus2024.
  ///
  /// In en, this message translates to:
  /// **'Total Surplus Distributed 2024'**
  String get totalSurplus2024;

  /// No description provided for @beneficiariesCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Beneficiaries: {count}'**
  String beneficiariesCount(String count);

  /// No description provided for @policyholdersFund.
  ///
  /// In en, this message translates to:
  /// **'Policyholders\' Fund'**
  String get policyholdersFund;

  /// No description provided for @shareholdersFund.
  ///
  /// In en, this message translates to:
  /// **'Shareholders\' Fund'**
  String get shareholdersFund;

  /// No description provided for @individualShare.
  ///
  /// In en, this message translates to:
  /// **'Individual Share'**
  String get individualShare;

  /// No description provided for @distributionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Distribution Date: {date}'**
  String distributionDateLabel(String date);

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @performanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  /// No description provided for @performanceOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform operations and operational revenues summary'**
  String get performanceOverviewSubtitle;

  /// No description provided for @totalActivePolicies.
  ///
  /// In en, this message translates to:
  /// **'Total Active Policies'**
  String get totalActivePolicies;

  /// No description provided for @totalPremiumsCollectedDzd.
  ///
  /// In en, this message translates to:
  /// **'Total Premiums Collected'**
  String get totalPremiumsCollectedDzd;

  /// No description provided for @totalUsersAdmin.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsersAdmin;

  /// No description provided for @activeRequestsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Active Requests'**
  String get activeRequestsAdmin;

  /// No description provided for @requireImmediateReview.
  ///
  /// In en, this message translates to:
  /// **'Require immediate review'**
  String get requireImmediateReview;

  /// No description provided for @takafulCompaniesCount.
  ///
  /// In en, this message translates to:
  /// **'Takaful Companies'**
  String get takafulCompaniesCount;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get totalRevenue;

  /// No description provided for @approvedOperatingBudget.
  ///
  /// In en, this message translates to:
  /// **'Approved Operating Budget'**
  String get approvedOperatingBudget;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @commissionsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Commissions'**
  String get commissionsAdmin;

  /// No description provided for @settingsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAdmin;

  /// No description provided for @legalRecord.
  ///
  /// In en, this message translates to:
  /// **'Legal Record'**
  String get legalRecord;

  /// No description provided for @commissionMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Commission Monitoring'**
  String get commissionMonitoring;

  /// No description provided for @totalCommissionsMonthYear.
  ///
  /// In en, this message translates to:
  /// **'Total Commissions {month} {year}'**
  String totalCommissionsMonthYear(String month, String year);

  /// No description provided for @fromLastMonth.
  ///
  /// In en, this message translates to:
  /// **'From last month'**
  String get fromLastMonth;

  /// No description provided for @companiesDetails.
  ///
  /// In en, this message translates to:
  /// **'Companies Details'**
  String get companiesDetails;

  /// No description provided for @commissionRatePct.
  ///
  /// In en, this message translates to:
  /// **'Commission Rate: {rate}%'**
  String commissionRatePct(String rate);

  /// No description provided for @dueCommission.
  ///
  /// In en, this message translates to:
  /// **'Due Commission'**
  String get dueCommission;

  /// No description provided for @totalPremiums.
  ///
  /// In en, this message translates to:
  /// **'Total Premiums'**
  String get totalPremiums;

  /// No description provided for @commissionsEvolution.
  ///
  /// In en, this message translates to:
  /// **'Commissions Evolution'**
  String get commissionsEvolution;

  /// No description provided for @highestMonth.
  ///
  /// In en, this message translates to:
  /// **'Highest Month'**
  String get highestMonth;

  /// No description provided for @legalAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Legal Audit Log'**
  String get legalAuditLog;

  /// No description provided for @auditLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed view of operations and actions performed on the system'**
  String get auditLogSubtitle;

  /// No description provided for @exportToPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPdf;

  /// No description provided for @actionType.
  ///
  /// In en, this message translates to:
  /// **'Action Type'**
  String get actionType;

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get timeRange;

  /// No description provided for @portal.
  ///
  /// In en, this message translates to:
  /// **'Portal'**
  String get portal;

  /// No description provided for @transactionsLog.
  ///
  /// In en, this message translates to:
  /// **'Transactions Log'**
  String get transactionsLog;

  /// No description provided for @masterConsole.
  ///
  /// In en, this message translates to:
  /// **'Master Console'**
  String get masterConsole;

  /// No description provided for @systemStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'System running normally | Last status update now'**
  String get systemStatusNormal;

  /// No description provided for @welcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcomePrefix;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome, our customer'**
  String get welcomeGuest;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @totalCoverage.
  ///
  /// In en, this message translates to:
  /// **'Total Coverage'**
  String get totalCoverage;

  /// No description provided for @policyNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Policy Number: {number}'**
  String policyNumberLabel(String number);

  /// No description provided for @monthlyPremiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Premium: {amount} DZD'**
  String monthlyPremiumLabel(String amount);

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Docs'**
  String get myDocuments;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @renewalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Renewal Alerts'**
  String get renewalAlerts;

  /// No description provided for @renewalDueIn.
  ///
  /// In en, this message translates to:
  /// **'Renewal due in {days} days'**
  String renewalDueIn(String days);

  /// No description provided for @renewalReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Please review your home insurance policy to avoid service interruption.'**
  String get renewalReviewNote;

  /// No description provided for @planTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel Insurance'**
  String get planTravel;

  /// No description provided for @planDisaster.
  ///
  /// In en, this message translates to:
  /// **'Disaster Insurance'**
  String get planDisaster;

  /// No description provided for @planLife.
  ///
  /// In en, this message translates to:
  /// **'Life Insurance'**
  String get planLife;

  /// No description provided for @planComprehensive.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Insurance'**
  String get planComprehensive;

  /// No description provided for @planPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial Insurance'**
  String get planPartial;

  /// No description provided for @latestTransactions.
  ///
  /// In en, this message translates to:
  /// **'Latest Transactions'**
  String get latestTransactions;

  /// No description provided for @monthlyPremiumPayment.
  ///
  /// In en, this message translates to:
  /// **'Monthly premium payment'**
  String get monthlyPremiumPayment;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @submittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted At'**
  String get submittedAt;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email to activate all features.'**
  String get emailVerificationRequired;

  /// No description provided for @confirmNow.
  ///
  /// In en, this message translates to:
  /// **'Confirm Now'**
  String get confirmNow;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @contactSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team for assistance'**
  String get contactSupportTeam;

  /// No description provided for @carIdentity.
  ///
  /// In en, this message translates to:
  /// **'Car Identity'**
  String get carIdentity;

  /// No description provided for @localCertificate.
  ///
  /// In en, this message translates to:
  /// **'Local Certificate'**
  String get localCertificate;

  /// No description provided for @uploadCarIdentityHint.
  ///
  /// In en, this message translates to:
  /// **'Upload the car identity document'**
  String get uploadCarIdentityHint;

  /// No description provided for @uploadLocalCertificateHint.
  ///
  /// In en, this message translates to:
  /// **'Upload the local insurance certificate'**
  String get uploadLocalCertificateHint;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocuments;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @paymentReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get paymentReceiptTitle;

  /// No description provided for @paymentReceiptSentToOperator.
  ///
  /// In en, this message translates to:
  /// **'Receipt sent to operator successfully'**
  String get paymentReceiptSentToOperator;

  /// No description provided for @paymentReceiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt Number'**
  String get paymentReceiptNumber;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @paymentConfirmedByClient.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed by client'**
  String get paymentConfirmedByClient;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @paymentVerified.
  ///
  /// In en, this message translates to:
  /// **'Payment Verified ✓'**
  String get paymentVerified;

  /// No description provided for @phoneNumberAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered'**
  String get phoneNumberAlreadyTaken;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @realtimeConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get realtimeConnecting;

  /// No description provided for @realtimeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get realtimeLive;

  /// No description provided for @realtimeRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying...'**
  String get realtimeRetrying;

  /// No description provided for @realtimeTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to Retry'**
  String get realtimeTapToRetry;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Hours Ago'**
  String get hoursAgo;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password Label'**
  String get passwordLabel;

  /// No description provided for @userPermissions.
  ///
  /// In en, this message translates to:
  /// **'User Permissions'**
  String get userPermissions;

  /// No description provided for @sinceLaunch.
  ///
  /// In en, this message translates to:
  /// **'Since Launch'**
  String get sinceLaunch;

  /// No description provided for @offerFamilyBundleDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Family Protection Bundle'**
  String get offerFamilyBundleDesc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @totalWallet.
  ///
  /// In en, this message translates to:
  /// **'Total Wallet'**
  String get totalWallet;

  /// No description provided for @walletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total accumulated balance from all participants'**
  String get walletSubtitle;

  /// No description provided for @salesTable.
  ///
  /// In en, this message translates to:
  /// **'Sales Table'**
  String get salesTable;

  /// No description provided for @addNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get addNewCustomer;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @shareLinkMessage.
  ///
  /// In en, this message translates to:
  /// **'Share Link Message'**
  String get shareLinkMessage;

  /// No description provided for @equipmentValue.
  ///
  /// In en, this message translates to:
  /// **'Equipment Value'**
  String get equipmentValue;

  /// No description provided for @startingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting Price'**
  String get startingPrice;

  /// No description provided for @mechanic.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get mechanic;

  /// No description provided for @offerNewDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'New Driver Offer'**
  String get offerNewDriverTitle;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(num km);

  /// No description provided for @engineer.
  ///
  /// In en, this message translates to:
  /// **'Engineer'**
  String get engineer;

  /// No description provided for @formulaExplanation1.
  ///
  /// In en, this message translates to:
  /// **'Formula Explanation 1'**
  String get formulaExplanation1;

  /// No description provided for @documentsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Documents Appear Here'**
  String get documentsAppearHere;

  /// No description provided for @calculateCarInsurance.
  ///
  /// In en, this message translates to:
  /// **'Calculate Car Insurance'**
  String get calculateCarInsurance;

  /// No description provided for @stepContribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution Step'**
  String get stepContribution;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @formulaExplanation2.
  ///
  /// In en, this message translates to:
  /// **'Formula Explanation 2'**
  String get formulaExplanation2;

  /// No description provided for @emergencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency Description'**
  String get emergencyDesc;

  /// No description provided for @solidarity.
  ///
  /// In en, this message translates to:
  /// **'Solidarity'**
  String get solidarity;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @theProcess.
  ///
  /// In en, this message translates to:
  /// **'Takaful Process'**
  String get theProcess;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @roadsideAssistance.
  ///
  /// In en, this message translates to:
  /// **'Roadside Assistance'**
  String get roadsideAssistance;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @coverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get coverage;

  /// No description provided for @shield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get shield;

  /// No description provided for @takafulConcept.
  ///
  /// In en, this message translates to:
  /// **'Takaful Concept'**
  String get takafulConcept;

  /// No description provided for @whyLegalFramework.
  ///
  /// In en, this message translates to:
  /// **'Why Legal Framework'**
  String get whyLegalFramework;

  /// No description provided for @notificationClaimTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim Notification Title'**
  String get notificationClaimTitle;

  /// No description provided for @offerDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer Deleted Successfully'**
  String get offerDeletedSuccess;

  /// No description provided for @islamicPrinciples.
  ///
  /// In en, this message translates to:
  /// **'Islamic Principles'**
  String get islamicPrinciples;

  /// No description provided for @nearbyGarages.
  ///
  /// In en, this message translates to:
  /// **'Nearby Garages'**
  String get nearbyGarages;

  /// No description provided for @offerRamadanTitle.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Offer'**
  String get offerRamadanTitle;

  /// No description provided for @plansManagement.
  ///
  /// In en, this message translates to:
  /// **'Plans Management'**
  String get plansManagement;

  /// No description provided for @nightMode.
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get nightMode;

  /// No description provided for @addOffer.
  ///
  /// In en, this message translates to:
  /// **'Add Offer'**
  String get addOffer;

  /// No description provided for @transparencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Transparency Description'**
  String get transparencyDesc;

  /// No description provided for @offerRamadanDesc.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Offer Description'**
  String get offerRamadanDesc;

  /// No description provided for @policyDetails.
  ///
  /// In en, this message translates to:
  /// **'Policy Details'**
  String get policyDetails;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @bestValueUnmarked.
  ///
  /// In en, this message translates to:
  /// **'Best Value (Unmarked)'**
  String get bestValueUnmarked;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'Per Year'**
  String get perYear;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image Uploaded'**
  String get imageUploaded;

  /// No description provided for @totalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Total Documents'**
  String get totalDocuments;

  /// No description provided for @ownership.
  ///
  /// In en, this message translates to:
  /// **'Ownership'**
  String get ownership;

  /// No description provided for @internationalStandards.
  ///
  /// In en, this message translates to:
  /// **'International Standards'**
  String get internationalStandards;

  /// No description provided for @stepPooling.
  ///
  /// In en, this message translates to:
  /// **'Pooling Step'**
  String get stepPooling;

  /// No description provided for @notificationSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'System Notification Title'**
  String get notificationSystemTitle;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Download Error'**
  String get downloadError;

  /// No description provided for @commerce.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get commerce;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @transparency.
  ///
  /// In en, this message translates to:
  /// **'Transparency'**
  String get transparency;

  /// No description provided for @takafulConceptDesc.
  ///
  /// In en, this message translates to:
  /// **'Takaful Concept Description'**
  String get takafulConceptDesc;

  /// No description provided for @carBrokenDown.
  ///
  /// In en, this message translates to:
  /// **'Car Broken Down'**
  String get carBrokenDown;

  /// No description provided for @actionCall.
  ///
  /// In en, this message translates to:
  /// **'Call Action'**
  String get actionCall;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @towing.
  ///
  /// In en, this message translates to:
  /// **'Towing'**
  String get towing;

  /// No description provided for @exampleValue.
  ///
  /// In en, this message translates to:
  /// **'Example: 2,000,000'**
  String get exampleValue;

  /// No description provided for @selectDriverAge.
  ///
  /// In en, this message translates to:
  /// **'Select Driver Age'**
  String get selectDriverAge;

  /// No description provided for @salesList.
  ///
  /// In en, this message translates to:
  /// **'Sales List'**
  String get salesList;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @roleManagement.
  ///
  /// In en, this message translates to:
  /// **'Role Management'**
  String get roleManagement;

  /// No description provided for @processingDurationDays.
  ///
  /// In en, this message translates to:
  /// **'Processing Days'**
  String get processingDurationDays;

  /// No description provided for @shariaSupervisionDesc.
  ///
  /// In en, this message translates to:
  /// **'Sharia Supervision Description'**
  String get shariaSupervisionDesc;

  /// No description provided for @lawyer.
  ///
  /// In en, this message translates to:
  /// **'Lawyer'**
  String get lawyer;

  /// No description provided for @offerFamilyBundleValidity.
  ///
  /// In en, this message translates to:
  /// **'Family Bundle Validity'**
  String get offerFamilyBundleValidity;

  /// No description provided for @roadsideAssistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadside Assistance Title'**
  String get roadsideAssistanceTitle;

  /// No description provided for @securityConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Security Configuration'**
  String get securityConfiguration;

  /// No description provided for @shariaInsuranceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sharia Insurance Subtitle'**
  String get shariaInsuranceSubtitle;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @stepSurplusDesc.
  ///
  /// In en, this message translates to:
  /// **'Surplus Step Description'**
  String get stepSurplusDesc;

  /// No description provided for @addNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Add New Plan'**
  String get addNewPlan;

  /// No description provided for @ratingWithStar.
  ///
  /// In en, this message translates to:
  /// **'Rating with Star'**
  String get ratingWithStar;

  /// No description provided for @editOffer.
  ///
  /// In en, this message translates to:
  /// **'Edit Offer'**
  String get editOffer;

  /// No description provided for @renewalAlert24H.
  ///
  /// In en, this message translates to:
  /// **'24H Renewal Alert'**
  String get renewalAlert24H;

  /// No description provided for @premiumDzd.
  ///
  /// In en, this message translates to:
  /// **'Premium (DZD)'**
  String get premiumDzd;

  /// No description provided for @ownerNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Owner Not Specified'**
  String get ownerNotSpecified;

  /// No description provided for @invalidMasterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Master Passcode'**
  String get invalidMasterPasscode;

  /// No description provided for @honestyDesc.
  ///
  /// In en, this message translates to:
  /// **'Honesty Description'**
  String get honestyDesc;

  /// No description provided for @createAdminAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create Sub-Admin Account'**
  String get createAdminAccountSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @offerNewDriverDesc.
  ///
  /// In en, this message translates to:
  /// **'New Driver Offer Description'**
  String get offerNewDriverDesc;

  /// No description provided for @noSalesCurrently.
  ///
  /// In en, this message translates to:
  /// **'No sales currently'**
  String get noSalesCurrently;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @notificationUserBody.
  ///
  /// In en, this message translates to:
  /// **'User Notification Body'**
  String get notificationUserBody;

  /// No description provided for @visionDesc.
  ///
  /// In en, this message translates to:
  /// **'Vision Description'**
  String get visionDesc;

  /// No description provided for @errorLoadingDataTryLater.
  ///
  /// In en, this message translates to:
  /// **'Error loading data, try again later'**
  String get errorLoadingDataTryLater;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// No description provided for @pressForImmediateSos.
  ///
  /// In en, this message translates to:
  /// **'Press for immediate SOS'**
  String get pressForImmediateSos;

  /// No description provided for @mutualCooperation.
  ///
  /// In en, this message translates to:
  /// **'Mutual Cooperation'**
  String get mutualCooperation;

  /// No description provided for @howTakafulWorks.
  ///
  /// In en, this message translates to:
  /// **'How Takaful Works'**
  String get howTakafulWorks;

  /// No description provided for @activityNature.
  ///
  /// In en, this message translates to:
  /// **'Activity Nature'**
  String get activityNature;

  /// No description provided for @policyholders.
  ///
  /// In en, this message translates to:
  /// **'Policyholders'**
  String get policyholders;

  /// No description provided for @yourProfit.
  ///
  /// In en, this message translates to:
  /// **'Your Profit'**
  String get yourProfit;

  /// No description provided for @adminRegistration.
  ///
  /// In en, this message translates to:
  /// **'Admin Registration'**
  String get adminRegistration;

  /// No description provided for @offerNewDriverValidity.
  ///
  /// In en, this message translates to:
  /// **'New Driver Offer Validity'**
  String get offerNewDriverValidity;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @legalFramework.
  ///
  /// In en, this message translates to:
  /// **'Legal Framework'**
  String get legalFramework;

  /// No description provided for @distributed.
  ///
  /// In en, this message translates to:
  /// **'Distributed'**
  String get distributed;

  /// No description provided for @honesty.
  ///
  /// In en, this message translates to:
  /// **'Honesty'**
  String get honesty;

  /// No description provided for @shariaSupervision.
  ///
  /// In en, this message translates to:
  /// **'Sharia Supervision'**
  String get shariaSupervision;

  /// No description provided for @yearUnit.
  ///
  /// In en, this message translates to:
  /// **'Years Old'**
  String get yearUnit;

  /// No description provided for @productAccreditation.
  ///
  /// In en, this message translates to:
  /// **'Product Accreditation'**
  String get productAccreditation;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @manageOffers.
  ///
  /// In en, this message translates to:
  /// **'Manage Offers'**
  String get manageOffers;

  /// No description provided for @requestFreeQuote.
  ///
  /// In en, this message translates to:
  /// **'Request Free Quote'**
  String get requestFreeQuote;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planName;

  /// No description provided for @offerRamadanValidity.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Offer Validity'**
  String get offerRamadanValidity;

  /// No description provided for @insuranceLawDesc.
  ///
  /// In en, this message translates to:
  /// **'Insurance Law Description'**
  String get insuranceLawDesc;

  /// No description provided for @annualInsurancePrice.
  ///
  /// In en, this message translates to:
  /// **'Annual Insurance Price'**
  String get annualInsurancePrice;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @solidarityDesc.
  ///
  /// In en, this message translates to:
  /// **'Solidarity Description'**
  String get solidarityDesc;

  /// No description provided for @retained.
  ///
  /// In en, this message translates to:
  /// **'Retained'**
  String get retained;

  /// No description provided for @emergencyAssistance.
  ///
  /// In en, this message translates to:
  /// **'Emergency Assistance'**
  String get emergencyAssistance;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @chooseByWilayaAndSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Choose by Wilaya and Specialty'**
  String get chooseByWilayaAndSpecialty;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data Backup'**
  String get dataBackup;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @operatorTakaful.
  ///
  /// In en, this message translates to:
  /// **'Takaful Operator'**
  String get operatorTakaful;

  /// No description provided for @recentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get recentSales;

  /// No description provided for @monthProfit.
  ///
  /// In en, this message translates to:
  /// **'Month Profit'**
  String get monthProfit;

  /// No description provided for @offerFamilyBundleTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Bundle Offer'**
  String get offerFamilyBundleTitle;

  /// No description provided for @myCommissionRate.
  ///
  /// In en, this message translates to:
  /// **'My Commission Rate'**
  String get myCommissionRate;

  /// No description provided for @premiumRate.
  ///
  /// In en, this message translates to:
  /// **'Premium Rate'**
  String get premiumRate;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature Coming Soon'**
  String get featureComingSoon;

  /// No description provided for @stepSurplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus Step'**
  String get stepSurplus;

  /// No description provided for @shareMyLink.
  ///
  /// In en, this message translates to:
  /// **'Share My Link'**
  String get shareMyLink;

  /// No description provided for @auditAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual Audit'**
  String get auditAnnual;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @appDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% discount for app subscribers'**
  String appDiscountLabel(int percent);

  /// No description provided for @driverAge.
  ///
  /// In en, this message translates to:
  /// **'Driver Age'**
  String get driverAge;

  /// No description provided for @formulaExplanation3.
  ///
  /// In en, this message translates to:
  /// **'Formula Explanation 3'**
  String get formulaExplanation3;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @noClaimsYet.
  ///
  /// In en, this message translates to:
  /// **'No claims yet'**
  String get noClaimsYet;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @directCallToTowing.
  ///
  /// In en, this message translates to:
  /// **'Direct Call to Towing'**
  String get directCallToTowing;

  /// No description provided for @contractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get contractor;

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get hourAgo;

  /// No description provided for @renewalAlertDays.
  ///
  /// In en, this message translates to:
  /// **'Renewal Alert Days'**
  String get renewalAlertDays;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @activityLogs.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get activityLogs;

  /// No description provided for @tires.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get tires;

  /// No description provided for @bestValueMarked.
  ///
  /// In en, this message translates to:
  /// **'Best Value (Marked)'**
  String get bestValueMarked;

  /// No description provided for @enterEquipmentValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter equipment value'**
  String get enterEquipmentValue;

  /// No description provided for @myClaims.
  ///
  /// In en, this message translates to:
  /// **'My Claims'**
  String get myClaims;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @surplusPercent.
  ///
  /// In en, this message translates to:
  /// **'Surplus Percent'**
  String get surplusPercent;

  /// No description provided for @stepProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection Step'**
  String get stepProtection;

  /// No description provided for @shariaCompliant.
  ///
  /// In en, this message translates to:
  /// **'Sharia Compliant'**
  String get shariaCompliant;

  /// No description provided for @notificationUserTitle.
  ///
  /// In en, this message translates to:
  /// **'User Notification Title'**
  String get notificationUserTitle;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @fileNewClaim.
  ///
  /// In en, this message translates to:
  /// **'File New Claim'**
  String get fileNewClaim;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @noTowingTrucksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No towing trucks available'**
  String get noTowingTrucksAvailable;

  /// No description provided for @saveOffer.
  ///
  /// In en, this message translates to:
  /// **'Save Offer'**
  String get saveOffer;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @enterGoodsValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter goods value'**
  String get enterGoodsValue;

  /// No description provided for @todayProfit.
  ///
  /// In en, this message translates to:
  /// **'Today Profit'**
  String get todayProfit;

  /// No description provided for @basis.
  ///
  /// In en, this message translates to:
  /// **'Basis'**
  String get basis;

  /// No description provided for @garageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Garage'**
  String get garageUnknown;

  /// No description provided for @registeredAt.
  ///
  /// In en, this message translates to:
  /// **'Registered At'**
  String get registeredAt;

  /// No description provided for @errorLoadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Error loading documents'**
  String get errorLoadingDocuments;

  /// No description provided for @noGaragesInThisArea.
  ///
  /// In en, this message translates to:
  /// **'No garages in this area'**
  String get noGaragesInThisArea;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Tameeni Elite'**
  String get appName;

  /// No description provided for @availablePlans.
  ///
  /// In en, this message translates to:
  /// **'Available Plans'**
  String get availablePlans;

  /// No description provided for @allTimeProfit.
  ///
  /// In en, this message translates to:
  /// **'All Time Profit'**
  String get allTimeProfit;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @offersManagement.
  ///
  /// In en, this message translates to:
  /// **'Offers Management'**
  String get offersManagement;

  /// No description provided for @insuranceRateNotice.
  ///
  /// In en, this message translates to:
  /// **'Insurance Rate Notice'**
  String get insuranceRateNotice;

  /// No description provided for @salesTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Tab Title'**
  String get salesTabTitle;

  /// No description provided for @whoWeAre.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get whoWeAre;

  /// No description provided for @howIsPriceCalculated.
  ///
  /// In en, this message translates to:
  /// **'How is price calculated'**
  String get howIsPriceCalculated;

  /// No description provided for @rafik.
  ///
  /// In en, this message translates to:
  /// **'Rafik'**
  String get rafik;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @shareholders.
  ///
  /// In en, this message translates to:
  /// **'Shareholders'**
  String get shareholders;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @internationalStandardsDesc.
  ///
  /// In en, this message translates to:
  /// **'International Standards Description'**
  String get internationalStandardsDesc;

  /// No description provided for @rafikCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Rafik Assistant Calculator'**
  String get rafikCalculatorTitle;

  /// No description provided for @verifiedGarages.
  ///
  /// In en, this message translates to:
  /// **'Verified Garages'**
  String get verifiedGarages;

  /// No description provided for @commercialProfit.
  ///
  /// In en, this message translates to:
  /// **'Commercial Profit'**
  String get commercialProfit;

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get expiresIn;

  /// No description provided for @selectProfessionType.
  ///
  /// In en, this message translates to:
  /// **'Select Profession Type'**
  String get selectProfessionType;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount Label'**
  String get discountLabel;

  /// No description provided for @takafulVsConventional.
  ///
  /// In en, this message translates to:
  /// **'Takaful vs Conventional'**
  String get takafulVsConventional;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @quoteResult.
  ///
  /// In en, this message translates to:
  /// **'Quote Result'**
  String get quoteResult;

  /// No description provided for @goodsValue.
  ///
  /// In en, this message translates to:
  /// **'Goods Value'**
  String get goodsValue;

  /// No description provided for @equalityDesc.
  ///
  /// In en, this message translates to:
  /// **'Equality Description'**
  String get equalityDesc;

  /// No description provided for @pickImageHint.
  ///
  /// In en, this message translates to:
  /// **'Pick Image Hint'**
  String get pickImageHint;

  /// No description provided for @noOffersYet.
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get noOffersYet;

  /// No description provided for @notificationSystemBody.
  ///
  /// In en, this message translates to:
  /// **'System Notification Body'**
  String get notificationSystemBody;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @isBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get isBestValue;

  /// No description provided for @insuranceLaw.
  ///
  /// In en, this message translates to:
  /// **'Insurance Law'**
  String get insuranceLaw;

  /// No description provided for @offerSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer saved successfully'**
  String get offerSavedSuccess;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @stepContributionDesc.
  ///
  /// In en, this message translates to:
  /// **'Contribution Step Description'**
  String get stepContributionDesc;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @monthlyInsurancePrice.
  ///
  /// In en, this message translates to:
  /// **'Monthly Insurance Price'**
  String get monthlyInsurancePrice;

  /// No description provided for @lastAccidentDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Last Accident Date (Optional)'**
  String get lastAccidentDateOptional;

  /// No description provided for @adminRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Admin registered successfully'**
  String get adminRegisteredSuccessfully;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @iconType.
  ///
  /// In en, this message translates to:
  /// **'Icon Type'**
  String get iconType;

  /// No description provided for @insuranceDocument.
  ///
  /// In en, this message translates to:
  /// **'Insurance Document'**
  String get insuranceDocument;

  /// No description provided for @masterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Master Passcode'**
  String get masterPasscode;

  /// No description provided for @masterPasscodeHint.
  ///
  /// In en, this message translates to:
  /// **'Master Passcode Hint'**
  String get masterPasscodeHint;

  /// No description provided for @planSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Plan saved successfully'**
  String get planSavedSuccessfully;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment Success Message'**
  String get paymentSuccessMessage;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @tireChange.
  ///
  /// In en, this message translates to:
  /// **'Tire Change'**
  String get tireChange;

  /// No description provided for @addNewOffer.
  ///
  /// In en, this message translates to:
  /// **'Add new promotional offer'**
  String get addNewOffer;

  /// No description provided for @enterRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Registration Number'**
  String get enterRegistrationNumber;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @adminClaims.
  ///
  /// In en, this message translates to:
  /// **'Admin Claims'**
  String get adminClaims;

  /// No description provided for @confirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Content'**
  String get confirmDeleteContent;

  /// No description provided for @agentDashboard.
  ///
  /// In en, this message translates to:
  /// **'Agent Dashboard'**
  String get agentDashboard;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @exitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Exit Confirmation Message'**
  String get exitConfirmMessage;

  /// No description provided for @algeriaUnited.
  ///
  /// In en, this message translates to:
  /// **'Algeria United'**
  String get algeriaUnited;

  /// No description provided for @professionType.
  ///
  /// In en, this message translates to:
  /// **'Profession Type'**
  String get professionType;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @notificationClaimBody.
  ///
  /// In en, this message translates to:
  /// **'Claim Notification Body'**
  String get notificationClaimBody;

  /// No description provided for @offerNameAr.
  ///
  /// In en, this message translates to:
  /// **'Offer Name (AR)'**
  String get offerNameAr;

  /// No description provided for @agentLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Login to your agent portal to manage policies and applications'**
  String get agentLoginDesc;

  /// No description provided for @whoWeAreTitle.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get whoWeAreTitle;

  /// No description provided for @atCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful Insurance Company'**
  String get atCompanyTitle;

  /// No description provided for @atCompanyDesc.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful is the first public takaful insurance company in Algeria, established in accordance with Islamic Sharia and operating under the official license issued by the Ministry of Finance. We offer various insurance products including car, enterprise, professional liability, and more, ensuring full transparency and separation between subscribers\' funds and shareholders\' funds.'**
  String get atCompanyDesc;

  /// No description provided for @atLocation.
  ///
  /// In en, this message translates to:
  /// **'Algiers'**
  String get atLocation;

  /// No description provided for @atLicensed.
  ///
  /// In en, this message translates to:
  /// **'Officially Licensed'**
  String get atLicensed;

  /// No description provided for @atPhilosophyTitle.
  ///
  /// In en, this message translates to:
  /// **'Takaful.. Protection with a Spirit of Cooperation'**
  String get atPhilosophyTitle;

  /// No description provided for @atPhilosophyDesc.
  ///
  /// In en, this message translates to:
  /// **'A system based on mutual solidarity where members contribute to a fund dedicated to compensating those affected among them, and the realized surpluses are distributed to subscribers.'**
  String get atPhilosophyDesc;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Insurance Services'**
  String get servicesTitle;

  /// No description provided for @serviceCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Car Insurance'**
  String get serviceCarTitle;

  /// No description provided for @serviceCarDesc.
  ///
  /// In en, this message translates to:
  /// **'RC from 3,000 DZD\nTR from 40,000 DZD'**
  String get serviceCarDesc;

  /// No description provided for @serviceCivilTitle.
  ///
  /// In en, this message translates to:
  /// **'Civil Liability'**
  String get serviceCivilTitle;

  /// No description provided for @serviceCivilDesc.
  ///
  /// In en, this message translates to:
  /// **'From 20,000 DZD'**
  String get serviceCivilDesc;

  /// No description provided for @serviceHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Insurance'**
  String get serviceHomeTitle;

  /// No description provided for @serviceHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'From 80,000 DZD'**
  String get serviceHomeDesc;

  /// No description provided for @serviceProfTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Activities'**
  String get serviceProfTitle;

  /// No description provided for @serviceProfDesc.
  ///
  /// In en, this message translates to:
  /// **'From 250,000 DZD'**
  String get serviceProfDesc;

  /// No description provided for @serviceCargoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cargo Transport'**
  String get serviceCargoTitle;

  /// No description provided for @serviceCargoDesc.
  ///
  /// In en, this message translates to:
  /// **'According to goods value'**
  String get serviceCargoDesc;

  /// No description provided for @serviceAgriTitle.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Activities'**
  String get serviceAgriTitle;

  /// No description provided for @serviceAgriDesc.
  ///
  /// In en, this message translates to:
  /// **'Special technical study'**
  String get serviceAgriDesc;

  /// No description provided for @protectionPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Takaful Protection Plans'**
  String get protectionPlansTitle;

  /// No description provided for @docsGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Required Documents Guide'**
  String get docsGuideTitle;

  /// No description provided for @docCars.
  ///
  /// In en, this message translates to:
  /// **'For Cars'**
  String get docCars;

  /// No description provided for @docCarsDesc.
  ///
  /// In en, this message translates to:
  /// **'Registration Card + Driver\'s License'**
  String get docCarsDesc;

  /// No description provided for @docCompanies.
  ///
  /// In en, this message translates to:
  /// **'For Companies'**
  String get docCompanies;

  /// No description provided for @docCompaniesDesc.
  ///
  /// In en, this message translates to:
  /// **'Commercial Register + Equipment List'**
  String get docCompaniesDesc;

  /// No description provided for @docTravelers.
  ///
  /// In en, this message translates to:
  /// **'For Travelers'**
  String get docTravelers;

  /// No description provided for @docTravelersDesc.
  ///
  /// In en, this message translates to:
  /// **'Passport Copy + Destination Details'**
  String get docTravelersDesc;

  /// No description provided for @legalFrameworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Sharia Framework'**
  String get legalFrameworkTitle;

  /// No description provided for @atLegalDesc.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful operates in accordance with Executive Decree 21-81 governing takaful activity, to ensure the highest levels of transparency and security for our subscribers.'**
  String get atLegalDesc;

  /// No description provided for @statsExp.
  ///
  /// In en, this message translates to:
  /// **'Years Experience'**
  String get statsExp;

  /// No description provided for @statsSubscribers.
  ///
  /// In en, this message translates to:
  /// **'Subscribers'**
  String get statsSubscribers;

  /// No description provided for @statsSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Customer Satisfaction'**
  String get statsSatisfaction;

  /// No description provided for @aiCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Al Ittihad Insurance Company'**
  String get aiCompanyTitle;

  /// No description provided for @aiCompanyDesc.
  ///
  /// In en, this message translates to:
  /// **'Al Ittihad is a leading traditional insurance company in Algeria, established under the official license issued by the Ministry of Finance. We offer a wide range of insurance products including auto, property, corporate, civil liability, and more, with a commitment to the highest standards of quality and transparency in serving our clients.'**
  String get aiCompanyDesc;

  /// No description provided for @aiPhilosophyTitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance.. Protection with Expertise and Responsibility'**
  String get aiPhilosophyTitle;

  /// No description provided for @aiPhilosophyDesc.
  ///
  /// In en, this message translates to:
  /// **'We rely on the traditional insurance system based on mutual compensation contracts, ensuring comprehensive coverage for our clients with a commitment to transparency and efficiency in claims processing.'**
  String get aiPhilosophyDesc;

  /// No description provided for @servicePropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Insurance'**
  String get servicePropertyTitle;

  /// No description provided for @servicePropertyDesc.
  ///
  /// In en, this message translates to:
  /// **'From 80,000 DZD'**
  String get servicePropertyDesc;

  /// No description provided for @serviceEnterpriseTitle.
  ///
  /// In en, this message translates to:
  /// **'Corporate Insurance'**
  String get serviceEnterpriseTitle;

  /// No description provided for @serviceEnterpriseDesc.
  ///
  /// In en, this message translates to:
  /// **'From 250,000 DZD'**
  String get serviceEnterpriseDesc;

  /// No description provided for @serviceAgriRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Risks'**
  String get serviceAgriRiskTitle;

  /// No description provided for @serviceAgriRiskDesc.
  ///
  /// In en, this message translates to:
  /// **'Special technical study'**
  String get serviceAgriRiskDesc;

  /// No description provided for @protectionPlansIttihadTitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance Protection Plans'**
  String get protectionPlansIttihadTitle;

  /// No description provided for @legalFrameworkIttihadTitle.
  ///
  /// In en, this message translates to:
  /// **'Regulatory and Legal Framework'**
  String get legalFrameworkIttihadTitle;

  /// No description provided for @aiLegalDesc.
  ///
  /// In en, this message translates to:
  /// **'Al Ittihad operates in accordance with Ordinance 95-07 relating to insurance and Law 06-04 amended and supplemented, to ensure the highest levels of transparency and security for our clients.'**
  String get aiLegalDesc;

  /// No description provided for @statsClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get statsClients;

  /// No description provided for @stepPoolingDesc.
  ///
  /// In en, this message translates to:
  /// **'Pooling Step Description'**
  String get stepPoolingDesc;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get systemNotifications;

  /// No description provided for @equality.
  ///
  /// In en, this message translates to:
  /// **'Equality'**
  String get equality;

  /// No description provided for @selectActivityNature.
  ///
  /// In en, this message translates to:
  /// **'Select Activity Nature'**
  String get selectActivityNature;

  /// No description provided for @stepProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Protection Step Description'**
  String get stepProtectionDesc;

  /// No description provided for @tabarruPercent.
  ///
  /// In en, this message translates to:
  /// **'Tabarru Percent'**
  String get tabarruPercent;

  /// No description provided for @loadingDocument.
  ///
  /// In en, this message translates to:
  /// **'Loading document'**
  String get loadingDocument;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuel;

  /// No description provided for @enterCarValueDzd.
  ///
  /// In en, this message translates to:
  /// **'Enter car value (DZD)'**
  String get enterCarValueDzd;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @completePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePayment;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @claims.
  ///
  /// In en, this message translates to:
  /// **'Claims'**
  String get claims;

  /// No description provided for @getAQuote.
  ///
  /// In en, this message translates to:
  /// **'Get a Quote'**
  String get getAQuote;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noClaims.
  ///
  /// In en, this message translates to:
  /// **'No claims'**
  String get noClaims;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get yourMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @protectionPacks.
  ///
  /// In en, this message translates to:
  /// **'Protection Packs'**
  String get protectionPacks;

  /// No description provided for @availableOffers.
  ///
  /// In en, this message translates to:
  /// **'Available Offers'**
  String get availableOffers;

  /// No description provided for @addToCompare.
  ///
  /// In en, this message translates to:
  /// **'Add to Compare'**
  String get addToCompare;

  /// No description provided for @removeFromCompare.
  ///
  /// In en, this message translates to:
  /// **'Remove from Compare'**
  String get removeFromCompare;

  /// No description provided for @comparisonList.
  ///
  /// In en, this message translates to:
  /// **'Comparison List'**
  String get comparisonList;

  /// No description provided for @startComparison.
  ///
  /// In en, this message translates to:
  /// **'Start Comparison Now'**
  String get startComparison;

  /// No description provided for @maxPlansComparison.
  ///
  /// In en, this message translates to:
  /// **'You can compare a maximum of 3 plans'**
  String get maxPlansComparison;

  /// No description provided for @noPlansSelected.
  ///
  /// In en, this message translates to:
  /// **'No plans selected for comparison'**
  String get noPlansSelected;

  /// No description provided for @selectAtLeastTwo.
  ///
  /// In en, this message translates to:
  /// **'Select at least two plans to compare'**
  String get selectAtLeastTwo;

  /// No description provided for @protectionPackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive insurance packages that ensure full protection for you and your family according to Takaful principles.'**
  String get protectionPackSubtitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @halalTakafulInsurance.
  ///
  /// In en, this message translates to:
  /// **'Takaful Insurance'**
  String get halalTakafulInsurance;

  /// No description provided for @myPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlans;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @calculateNow.
  ///
  /// In en, this message translates to:
  /// **'Calculate Now ←'**
  String get calculateNow;

  /// No description provided for @roadsideServices.
  ///
  /// In en, this message translates to:
  /// **'Roadside Services'**
  String get roadsideServices;

  /// No description provided for @roadsideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We connect you to the best insurance solutions and roadside services in one place'**
  String get roadsideSubtitle;

  /// No description provided for @takafulTitle.
  ///
  /// In en, this message translates to:
  /// **'Takaful Platform.. Cooperation and Safety'**
  String get takafulTitle;

  /// No description provided for @takafulDescription.
  ///
  /// In en, this message translates to:
  /// **'An Islamic insurance system based on the principle of solidarity — everyone contributes to a single fund to compensate those affected. The company acts as an agent managing the fund for a known fee, and is not the owner of subscribers\' funds.'**
  String get takafulDescription;

  /// No description provided for @howTakafulWorksAction.
  ///
  /// In en, this message translates to:
  /// **'How Takaful Works? ←'**
  String get howTakafulWorksAction;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String fromPrice(String price);

  /// No description provided for @takafulHalalNotice.
  ///
  /// In en, this message translates to:
  /// **'Takaful Insurance'**
  String get takafulHalalNotice;

  /// No description provided for @rafikCalculator.
  ///
  /// In en, this message translates to:
  /// **'🔢 Rafik Calculator'**
  String get rafikCalculator;

  /// No description provided for @rafikSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your car value and calculate your premium automatically\n(Price = 0.4% of car value)'**
  String get rafikSubtitle;

  /// No description provided for @modernPacksCompetitivePrices.
  ///
  /// In en, this message translates to:
  /// **'Modern Packages at Competitive Prices'**
  String get modernPacksCompetitivePrices;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete User Confirmation'**
  String get deleteUserConfirmation;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @planAutoRC.
  ///
  /// In en, this message translates to:
  /// **'Auto Third-Party Liability (RC)'**
  String get planAutoRC;

  /// No description provided for @planHome.
  ///
  /// In en, this message translates to:
  /// **'Home Insurance'**
  String get planHome;

  /// No description provided for @performanceStats.
  ///
  /// In en, this message translates to:
  /// **'Performance Statistics'**
  String get performanceStats;

  /// No description provided for @monthlySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscriptions'**
  String get monthlySubscriptions;

  /// No description provided for @totalSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Total Subscriptions'**
  String get totalSubscriptions;

  /// No description provided for @paidSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Paid Subscriptions'**
  String get paidSubscriptions;

  /// No description provided for @claimsVsSurplus.
  ///
  /// In en, this message translates to:
  /// **'Claims vs Surplus'**
  String get claimsVsSurplus;

  /// No description provided for @insurancePacksAndServices.
  ///
  /// In en, this message translates to:
  /// **'Takaful Products and Services'**
  String get insurancePacksAndServices;

  /// No description provided for @quoteRequirements.
  ///
  /// In en, this message translates to:
  /// **'Quote Request Requirements'**
  String get quoteRequirements;

  /// No description provided for @whyLegal.
  ///
  /// In en, this message translates to:
  /// **'Why are we legal?'**
  String get whyLegal;

  /// No description provided for @takafulPhilosophy.
  ///
  /// In en, this message translates to:
  /// **'Takaful.. protection with a spirit of cooperation'**
  String get takafulPhilosophy;

  /// No description provided for @generalError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String generalError(String error);

  /// No description provided for @documentId.
  ///
  /// In en, this message translates to:
  /// **'Document ID'**
  String get documentId;

  /// No description provided for @subscriberData.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Data'**
  String get subscriberData;

  /// No description provided for @insuranceDetails.
  ///
  /// In en, this message translates to:
  /// **'Insurance Coverage Details'**
  String get insuranceDetails;

  /// No description provided for @attachedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attached Documents'**
  String get attachedDocuments;

  /// No description provided for @noDocumentsAttached.
  ///
  /// In en, this message translates to:
  /// **'No documents attached to this request'**
  String get noDocumentsAttached;

  /// No description provided for @attachedDocument.
  ///
  /// In en, this message translates to:
  /// **'Attached Document'**
  String get attachedDocument;

  /// No description provided for @viewFile.
  ///
  /// In en, this message translates to:
  /// **'View File'**
  String get viewFile;

  /// No description provided for @regulatoryDecision.
  ///
  /// In en, this message translates to:
  /// **'Regulatory Decision Details & Notes'**
  String get regulatoryDecision;

  /// No description provided for @regulatoryDecisionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reason for approval, rejection, or modification request here...'**
  String get regulatoryDecisionHint;

  /// No description provided for @receiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Manual Payment Proof Receipt'**
  String get receiptPhoto;

  /// No description provided for @fullSizeView.
  ///
  /// In en, this message translates to:
  /// **'Full Size Preview'**
  String get fullSizeView;

  /// No description provided for @paidVerified.
  ///
  /// In en, this message translates to:
  /// **'Subscription payment verified successfully'**
  String get paidVerified;

  /// No description provided for @operatorDecisionMade.
  ///
  /// In en, this message translates to:
  /// **'A final decision has been made on this request by the operator'**
  String get operatorDecisionMade;

  /// No description provided for @requestModification.
  ///
  /// In en, this message translates to:
  /// **'Request Modification'**
  String get requestModification;

  /// No description provided for @enterReasonFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason for rejection or modification first!'**
  String get enterReasonFirst;

  /// No description provided for @requestUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Takaful request status updated successfully'**
  String get requestUpdateSuccess;

  /// No description provided for @operatorPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Operator Portal'**
  String get operatorPortalTitle;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @roadsideAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadside & Repair Services'**
  String get roadsideAppTitle;

  /// No description provided for @certifiedGaragesDirectory.
  ///
  /// In en, this message translates to:
  /// **'Certified Workshops Directory'**
  String get certifiedGaragesDirectory;

  /// No description provided for @searchGarageHint.
  ///
  /// In en, this message translates to:
  /// **'Search by workshop name or province...'**
  String get searchGarageHint;

  /// No description provided for @gpsScanningMessage.
  ///
  /// In en, this message translates to:
  /// **'Reading your location via GPS and locating nearest responder...'**
  String get gpsScanningMessage;

  /// No description provided for @locationDeterminedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location determined! Nearest responder is available now'**
  String get locationDeterminedSuccess;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distanceAway(String distance);

  /// No description provided for @callDirectlyNow.
  ///
  /// In en, this message translates to:
  /// **'Call Directly Now'**
  String get callDirectlyNow;

  /// No description provided for @takafulDefinitionHeader.
  ///
  /// In en, this message translates to:
  /// **'Introduction to Takaful & Services'**
  String get takafulDefinitionHeader;

  /// No description provided for @appSubscriberDiscount.
  ///
  /// In en, this message translates to:
  /// **'{discount}% discount for app subscribers'**
  String appSubscriberDiscount(String discount);

  /// No description provided for @callItemButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callItemButton;

  /// No description provided for @sosTitle.
  ///
  /// In en, this message translates to:
  /// **'Rescue at the Press of a Button'**
  String get sosTitle;

  /// No description provided for @sosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to request emergency assistance and locate you instantly'**
  String get sosSubtitle;

  /// No description provided for @fallbackTruckName.
  ///
  /// In en, this message translates to:
  /// **'Uncle Ahmed for Rapid Repair & Towing'**
  String get fallbackTruckName;

  /// No description provided for @noGaragesFound.
  ///
  /// In en, this message translates to:
  /// **'No workshops found matching the filtering options.'**
  String get noGaragesFound;

  /// No description provided for @errorLoadingGarages.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading certified workshops. Please check your internet connection.'**
  String get errorLoadingGarages;

  /// No description provided for @callingPerson.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}...'**
  String callingPerson(String name);

  /// No description provided for @callConfirmationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to call {name} at {phone}?'**
  String callConfirmationPrompt(String name, String phone);

  /// No description provided for @specialtyMechanic.
  ///
  /// In en, this message translates to:
  /// **'General Mechanic'**
  String get specialtyMechanic;

  /// No description provided for @specialtyElectrician.
  ///
  /// In en, this message translates to:
  /// **'Auto Electrician'**
  String get specialtyElectrician;

  /// No description provided for @specialtyTires.
  ///
  /// In en, this message translates to:
  /// **'Tire Repair'**
  String get specialtyTires;

  /// No description provided for @specialtyDefault.
  ///
  /// In en, this message translates to:
  /// **'Certified Maintenance'**
  String get specialtyDefault;

  /// No description provided for @callingDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct Call'**
  String get callingDirect;

  /// No description provided for @provinceAlgiers.
  ///
  /// In en, this message translates to:
  /// **'Algiers'**
  String get provinceAlgiers;

  /// No description provided for @provinceOran.
  ///
  /// In en, this message translates to:
  /// **'Oran'**
  String get provinceOran;

  /// No description provided for @provinceConstantine.
  ///
  /// In en, this message translates to:
  /// **'Constantine'**
  String get provinceConstantine;

  /// No description provided for @provinceBlida.
  ///
  /// In en, this message translates to:
  /// **'Blida'**
  String get provinceBlida;

  /// No description provided for @provinceBoumerdes.
  ///
  /// In en, this message translates to:
  /// **'Boumerdes'**
  String get provinceBoumerdes;

  /// No description provided for @wilayaFilterPrefix.
  ///
  /// In en, this message translates to:
  /// **'Province: '**
  String get wilayaFilterPrefix;

  /// No description provided for @specialtyFilterPrefix.
  ///
  /// In en, this message translates to:
  /// **'Specialty: '**
  String get specialtyFilterPrefix;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @specialtyMechanicFilter.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get specialtyMechanicFilter;

  /// No description provided for @specialtyElectricianFilter.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get specialtyElectricianFilter;

  /// No description provided for @specialtyTiresFilter.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get specialtyTiresFilter;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get addressLabel;

  /// No description provided for @adminDashboardProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit Section (Agency Fee)'**
  String get adminDashboardProfit;

  /// No description provided for @adminDashboardSales.
  ///
  /// In en, this message translates to:
  /// **'Sales List (Name – Company – Amount)'**
  String get adminDashboardSales;

  /// No description provided for @adminDashboardWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet (Total Balance from All Subscribers)'**
  String get adminDashboardWallet;

  /// No description provided for @agriIndus.
  ///
  /// In en, this message translates to:
  /// **'Agricultural & Industrial Activities (Agricole & Industriel)'**
  String get agriIndus;

  /// No description provided for @agriIndusDesc.
  ///
  /// In en, this message translates to:
  /// **'Insurance for equipment, crops, factories and heavy machinery'**
  String get agriIndusDesc;

  /// No description provided for @agriIndusPrice.
  ///
  /// In en, this message translates to:
  /// **'Prices: subject to a special technical study (based on facility size)'**
  String get agriIndusPrice;

  /// No description provided for @agriIndusTargets.
  ///
  /// In en, this message translates to:
  /// **'Farmers, agricultural investors, and factory owners'**
  String get agriIndusTargets;

  /// No description provided for @autoInsurance.
  ///
  /// In en, this message translates to:
  /// **'Motor Vehicle Insurance (Automobile)'**
  String get autoInsurance;

  /// No description provided for @carValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Car Value (DZD)'**
  String get carValueLabel;

  /// No description provided for @cargoDesc.
  ///
  /// In en, this message translates to:
  /// **'Protection of transported goods (road, sea, air) against damage or loss'**
  String get cargoDesc;

  /// No description provided for @cargoStartingPrice.
  ///
  /// In en, this message translates to:
  /// **'Prices: based on cargo value and route'**
  String get cargoStartingPrice;

  /// No description provided for @cargoTargets.
  ///
  /// In en, this message translates to:
  /// **'Import/export companies and distributors'**
  String get cargoTargets;

  /// No description provided for @cargoTransport.
  ///
  /// In en, this message translates to:
  /// **'Cargo Transport Insurance (Transport de Marchandises)'**
  String get cargoTransport;

  /// No description provided for @categoryAuto.
  ///
  /// In en, this message translates to:
  /// **'Automobile'**
  String get categoryAuto;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @commercialDesc.
  ///
  /// In en, this message translates to:
  /// **'Protection for shops and warehouses (fire, theft, glass breakage, electrical damage)'**
  String get commercialDesc;

  /// No description provided for @commercialInsurance.
  ///
  /// In en, this message translates to:
  /// **'Commercial Activity Insurance (Activités Commerciales)'**
  String get commercialInsurance;

  /// No description provided for @commercialStartingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting from 80,000 DZD (commercial multi-risk)'**
  String get commercialStartingPrice;

  /// No description provided for @commercialTargets.
  ///
  /// In en, this message translates to:
  /// **'Shop owners, supermarkets, and restaurants'**
  String get commercialTargets;

  /// No description provided for @commissionEarned.
  ///
  /// In en, this message translates to:
  /// **'Commission Earned'**
  String get commissionEarned;

  /// No description provided for @decree2181Desc.
  ///
  /// In en, this message translates to:
  /// **'Takaful constitution, financial separation, and takaful window'**
  String get decree2181Desc;

  /// No description provided for @decree2181Title.
  ///
  /// In en, this message translates to:
  /// **'Executive Decree No. 21-81'**
  String get decree2181Title;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Destination'**
  String get destinationLabel;

  /// No description provided for @discountBadge.
  ///
  /// In en, this message translates to:
  /// **'🏅 {percent}% Discount'**
  String discountBadge(int percent);

  /// No description provided for @durationDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Duration (days)'**
  String get durationDaysLabel;

  /// No description provided for @emergencySosBtn.
  ///
  /// In en, this message translates to:
  /// **'Emergency Button (SOS Dépannage)'**
  String get emergencySosBtn;

  /// No description provided for @estimatedPremiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Premium (0.4%)'**
  String get estimatedPremiumLabel;

  /// No description provided for @fastShariaCompensations.
  ///
  /// In en, this message translates to:
  /// **'Fast and Sharia-compliant compensations'**
  String get fastShariaCompensations;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @filePathError.
  ///
  /// In en, this message translates to:
  /// **'File path not available'**
  String get filePathError;

  /// No description provided for @fileReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read file data'**
  String get fileReadError;

  /// No description provided for @findRepairman.
  ///
  /// In en, this message translates to:
  /// **'Certified Garage Directory (Find a Repairman)'**
  String get findRepairman;

  /// No description provided for @garageCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Garage card: rating, location, and discount badge'**
  String get garageCardDetails;

  /// No description provided for @goodsNatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Goods Nature'**
  String get goodsNatureLabel;

  /// No description provided for @halalCooperativeInsurance.
  ///
  /// In en, this message translates to:
  /// **'Takaful cooperative insurance compliant with Islamic Law'**
  String get halalCooperativeInsurance;

  /// No description provided for @individualsAndCompanies.
  ///
  /// In en, this message translates to:
  /// **'Individuals and Companies (private and utility vehicles)'**
  String get individualsAndCompanies;

  /// No description provided for @lastAccidentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Accident Date (Optional)'**
  String get lastAccidentDateLabel;

  /// No description provided for @multirisquePro.
  ///
  /// In en, this message translates to:
  /// **'Professional & Craft Activities (Multirisque Pro)'**
  String get multirisquePro;

  /// No description provided for @multirisqueProDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive insurance for office premises and professional equipment'**
  String get multirisqueProDesc;

  /// No description provided for @multirisqueProStartingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting from 250,000 DZD (professional multi-risk)'**
  String get multirisqueProStartingPrice;

  /// No description provided for @multirisqueProTargets.
  ///
  /// In en, this message translates to:
  /// **'Workshop owners and freelance professionals'**
  String get multirisqueProTargets;

  /// No description provided for @passportPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Passport Photo'**
  String get passportPhotoLabel;

  /// No description provided for @planAutoTR.
  ///
  /// In en, this message translates to:
  /// **'All-Risk Motor Insurance'**
  String get planAutoTR;

  /// No description provided for @rcStartingFrom.
  ///
  /// In en, this message translates to:
  /// **'Civil Liability (RC): starting from 3,000 DZD'**
  String get rcStartingFrom;

  /// No description provided for @rcpDesc.
  ///
  /// In en, this message translates to:
  /// **'Protects professionals from liability for errors committed at work'**
  String get rcpDesc;

  /// No description provided for @rcpLabel.
  ///
  /// In en, this message translates to:
  /// **'Professional Civil Liability (RCP)'**
  String get rcpLabel;

  /// No description provided for @rcpStartingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting from 20,000 DZD'**
  String get rcpStartingPrice;

  /// No description provided for @rcpTargets.
  ///
  /// In en, this message translates to:
  /// **'Doctors, lawyers, engineers, and tradespeople'**
  String get rcpTargets;

  /// No description provided for @residenceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence Type'**
  String get residenceTypeLabel;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route / Path'**
  String get routeLabel;

  /// No description provided for @shariaNationalSupervision.
  ///
  /// In en, this message translates to:
  /// **'Under the supervision of the National Sharia Board'**
  String get shariaNationalSupervision;

  /// No description provided for @shariaSupervisionNational.
  ///
  /// In en, this message translates to:
  /// **'National Sharia Supervision'**
  String get shariaSupervisionNational;

  /// No description provided for @socialTakaful.
  ///
  /// In en, this message translates to:
  /// **'Social Takaful'**
  String get socialTakaful;

  /// No description provided for @sosFeatureSpeed.
  ///
  /// In en, this message translates to:
  /// **'For speed: emergency assistance at the press of a button'**
  String get sosFeatureSpeed;

  /// No description provided for @subscribersFund.
  ///
  /// In en, this message translates to:
  /// **'Subscribers\' Fund'**
  String get subscribersFund;

  /// No description provided for @takafulDefinition.
  ///
  /// In en, this message translates to:
  /// **'Takaful is an Islamic insurance system based on the principle of solidarity; everyone contributes to a common fund to compensate those affected. We do not profit from your risks, but manage your cooperation professionally and transparently according to Sharia.'**
  String get takafulDefinition;

  /// No description provided for @takafulDefinitionTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Takaful Insurance?'**
  String get takafulDefinitionTitle;

  /// No description provided for @tousRisquesPlusRC.
  ///
  /// In en, this message translates to:
  /// **'All-Risk Insurance (Tous Risques) + Civil Liability (RC)'**
  String get tousRisquesPlusRC;

  /// No description provided for @trStartingFrom.
  ///
  /// In en, this message translates to:
  /// **'All-Risk Insurance (Tous Risques): starting from 40,000 DZD'**
  String get trStartingFrom;

  /// No description provided for @unauthenticatedErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'User is not authenticated'**
  String get unauthenticatedErrorDetail;

  /// No description provided for @wakalaPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Agency Principle (Al-Wakala)'**
  String get wakalaPrinciple;

  /// No description provided for @whyWeAreLegal.
  ///
  /// In en, this message translates to:
  /// **'Why Are We Legally Compliant?'**
  String get whyWeAreLegal;

  /// No description provided for @claimsRequests.
  ///
  /// In en, this message translates to:
  /// **'Claims Requests'**
  String get claimsRequests;

  /// No description provided for @claimProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Processing claims submitted by policyholders'**
  String get claimProcessingSubtitle;

  /// No description provided for @claimsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Claims Value Trend (in thousands DZD)'**
  String get claimsChartTitle;

  /// No description provided for @claimAcceptedMsg.
  ///
  /// In en, this message translates to:
  /// **'Claim accepted successfully'**
  String get claimAcceptedMsg;

  /// No description provided for @claimRejectedMsg.
  ///
  /// In en, this message translates to:
  /// **'Claim rejected'**
  String get claimRejectedMsg;

  /// No description provided for @claimUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating claim'**
  String get claimUpdateError;

  /// No description provided for @claimErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get claimErrorOccurred;

  /// No description provided for @claimsSubmittedViaApp.
  ///
  /// In en, this message translates to:
  /// **'Via App'**
  String get claimsSubmittedViaApp;

  /// No description provided for @claimRequestWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim Request'**
  String get claimRequestWizardTitle;

  /// No description provided for @generalClaim.
  ///
  /// In en, this message translates to:
  /// **'General Claim'**
  String get generalClaim;

  /// No description provided for @clientDocuments.
  ///
  /// In en, this message translates to:
  /// **'Client Documents'**
  String get clientDocuments;

  /// No description provided for @nationalIdCard.
  ///
  /// In en, this message translates to:
  /// **'National ID Card'**
  String get nationalIdCard;

  /// No description provided for @proofOfResidence.
  ///
  /// In en, this message translates to:
  /// **'Proof of Residence'**
  String get proofOfResidence;

  /// No description provided for @openDocLink.
  ///
  /// In en, this message translates to:
  /// **'Open document link'**
  String get openDocLink;

  /// No description provided for @closeDialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeDialog;

  /// No description provided for @acceptClaim.
  ///
  /// In en, this message translates to:
  /// **'Accept Claim'**
  String get acceptClaim;

  /// No description provided for @rejectClaim.
  ///
  /// In en, this message translates to:
  /// **'Reject Claim'**
  String get rejectClaim;

  /// No description provided for @takafulClient.
  ///
  /// In en, this message translates to:
  /// **'Takaful Client'**
  String get takafulClient;

  /// No description provided for @alIttihadClient.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Client'**
  String get alIttihadClient;

  /// No description provided for @requiredDocsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} required documents'**
  String requiredDocsCount(int count);

  /// No description provided for @insuranceRequest.
  ///
  /// In en, this message translates to:
  /// **'Insurance Request'**
  String get insuranceRequest;

  /// No description provided for @selectInsuranceService.
  ///
  /// In en, this message translates to:
  /// **'Select the appropriate insurance service'**
  String get selectInsuranceService;

  /// No description provided for @policyholderInfo.
  ///
  /// In en, this message translates to:
  /// **'Policyholder Information'**
  String get policyholderInfo;

  /// No description provided for @requestedInsuranceAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Insurance Amount (DZD)'**
  String get requestedInsuranceAmount;

  /// No description provided for @enterAmountDzd.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in Algerian Dinars'**
  String get enterAmountDzd;

  /// No description provided for @requiredDocsForService.
  ///
  /// In en, this message translates to:
  /// **'Required documents for this service'**
  String get requiredDocsForService;

  /// No description provided for @maxFileSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Maximum file size 5MB (PDF or images)'**
  String get maxFileSizeHint;

  /// No description provided for @mustUploadAllDocs.
  ///
  /// In en, this message translates to:
  /// **'All documents must be uploaded to proceed'**
  String get mustUploadAllDocs;

  /// No description provided for @insuranceRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Insurance request submitted successfully'**
  String get insuranceRequestSuccess;

  /// No description provided for @insuranceSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'The team will review your insurance request and notify you of the approval decision as soon as possible. You can track your request status in My Policies.'**
  String get insuranceSuccessDesc;

  /// No description provided for @trackMyRequests.
  ///
  /// In en, this message translates to:
  /// **'Track My Requests'**
  String get trackMyRequests;

  /// No description provided for @nextUploadDocs.
  ///
  /// In en, this message translates to:
  /// **'Next: Upload Documents'**
  String get nextUploadDocs;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @sendInsuranceRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Insurance Request'**
  String get sendInsuranceRequest;

  /// No description provided for @pleaseFillAllFieldsCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all personal data correctly'**
  String get pleaseFillAllFieldsCorrectly;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds the limit (5MB)'**
  String get fileTooLarge;

  /// No description provided for @pdfImageLimit.
  ///
  /// In en, this message translates to:
  /// **'PDF / Image (Max 5MB)'**
  String get pdfImageLimit;

  /// No description provided for @quoteRequest.
  ///
  /// In en, this message translates to:
  /// **'Quote Request'**
  String get quoteRequest;

  /// No description provided for @sendQuoteRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Quote Request'**
  String get sendQuoteRequest;

  /// No description provided for @quoteSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'The quote request will be studied by the institution\'s experts, and we will contact you as soon as possible.'**
  String get quoteSuccessDesc;

  /// No description provided for @quoteRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Quote request submitted successfully'**
  String get quoteRequestSuccess;

  /// No description provided for @claimRequest.
  ///
  /// In en, this message translates to:
  /// **'Claim Request'**
  String get claimRequest;

  /// No description provided for @claimSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compensation for damages caused by accidents'**
  String get claimSubtitle;

  /// No description provided for @claimStep1.
  ///
  /// In en, this message translates to:
  /// **'Accident Documents'**
  String get claimStep1;

  /// No description provided for @claimStep2.
  ///
  /// In en, this message translates to:
  /// **'Accident Details'**
  String get claimStep2;

  /// No description provided for @claimStep3.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get claimStep3;

  /// No description provided for @officialRequiredDocs.
  ///
  /// In en, this message translates to:
  /// **'Official required documents'**
  String get officialRequiredDocs;

  /// No description provided for @drivingLicenseBothSides.
  ///
  /// In en, this message translates to:
  /// **'Driving License (Both Sides)'**
  String get drivingLicenseBothSides;

  /// No description provided for @carteGriseLabel.
  ///
  /// In en, this message translates to:
  /// **'Grey Card'**
  String get carteGriseLabel;

  /// No description provided for @friendlyReportOptional.
  ///
  /// In en, this message translates to:
  /// **'Friendly Report (Optional)'**
  String get friendlyReportOptional;

  /// No description provided for @carPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'Car photos — {count}/4 photos'**
  String carPhotosCount(int count);

  /// No description provided for @carPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Photograph the car from the four angles to speed up processing'**
  String get carPhotosHint;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get tapToAdd;

  /// No description provided for @accidentInfo.
  ///
  /// In en, this message translates to:
  /// **'Accident Information'**
  String get accidentInfo;

  /// No description provided for @associatedPolicy.
  ///
  /// In en, this message translates to:
  /// **'Associated Policy'**
  String get associatedPolicy;

  /// No description provided for @accidentDate.
  ///
  /// In en, this message translates to:
  /// **'Accident Date'**
  String get accidentDate;

  /// No description provided for @accidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Accident Location'**
  String get accidentLocation;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter the accident location'**
  String get pleaseEnterLocation;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'City, neighborhood, street...'**
  String get locationHint;

  /// No description provided for @accidentDescription.
  ///
  /// In en, this message translates to:
  /// **'Accident Description'**
  String get accidentDescription;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a detailed description (at least 20 characters)'**
  String get pleaseEnterDescription;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Explain what happened in detail...'**
  String get descriptionHint;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// No description provided for @stage1.
  ///
  /// In en, this message translates to:
  /// **'Stage 1'**
  String get stage1;

  /// No description provided for @fileReceived.
  ///
  /// In en, this message translates to:
  /// **'File received'**
  String get fileReceived;

  /// No description provided for @stage2.
  ///
  /// In en, this message translates to:
  /// **'Stage 2'**
  String get stage2;

  /// No description provided for @expertAssignment.
  ///
  /// In en, this message translates to:
  /// **'Expert assigned (Name + Phone + Location)'**
  String get expertAssignment;

  /// No description provided for @stage3.
  ///
  /// In en, this message translates to:
  /// **'Stage 3'**
  String get stage3;

  /// No description provided for @directRepairOrder.
  ///
  /// In en, this message translates to:
  /// **'Direct Repair Order (QR Code or workshop access number)'**
  String get directRepairOrder;

  /// No description provided for @trackingStages.
  ///
  /// In en, this message translates to:
  /// **'Tracking Stages'**
  String get trackingStages;

  /// No description provided for @claimSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'The claim request has been registered successfully. An expert will be assigned as soon as possible, and you will receive a repair order notification.'**
  String get claimSuccessDesc;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @uploadedCheck.
  ///
  /// In en, this message translates to:
  /// **'Uploaded ✓'**
  String get uploadedCheck;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @backPhoto.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backPhoto;

  /// No description provided for @rightSide.
  ///
  /// In en, this message translates to:
  /// **'Right Side'**
  String get rightSide;

  /// No description provided for @leftSide.
  ///
  /// In en, this message translates to:
  /// **'Left Side'**
  String get leftSide;

  /// No description provided for @claimRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Claim request submitted successfully'**
  String get claimRequestSuccess;

  /// No description provided for @nextIncidentDetails.
  ///
  /// In en, this message translates to:
  /// **'Next: Incident Details'**
  String get nextIncidentDetails;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendClaimRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Claim'**
  String get sendClaimRequest;

  /// No description provided for @insuranceRequests.
  ///
  /// In en, this message translates to:
  /// **'Insurance Requests'**
  String get insuranceRequests;

  /// No description provided for @claimRequests.
  ///
  /// In en, this message translates to:
  /// **'Claim Requests'**
  String get claimRequests;

  /// No description provided for @newInsuranceRequest.
  ///
  /// In en, this message translates to:
  /// **'New Insurance Request'**
  String get newInsuranceRequest;

  /// No description provided for @newClaimRequest.
  ///
  /// In en, this message translates to:
  /// **'New Claim Request'**
  String get newClaimRequest;

  /// No description provided for @noInsuranceRequests.
  ///
  /// In en, this message translates to:
  /// **'No insurance requests yet'**
  String get noInsuranceRequests;

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusReceived;

  /// No description provided for @statusInsurancePending.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusInsurancePending;

  /// No description provided for @stageReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get stageReceived;

  /// No description provided for @stageExpertAssigned.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get stageExpertAssigned;

  /// No description provided for @stageRepairAuthorised.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get stageRepairAuthorised;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @requestAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your request has been accepted!'**
  String get requestAcceptedTitle;

  /// No description provided for @policyReadyForPayment.
  ///
  /// In en, this message translates to:
  /// **'{planName} policy is ready for payment.'**
  String policyReadyForPayment(String planName);

  /// No description provided for @notifiedWhenApproved.
  ///
  /// In en, this message translates to:
  /// **'You will be notified once {companyName} operator approves.'**
  String notifiedWhenApproved(String companyName);

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get unspecified;

  /// No description provided for @supermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get supermarket;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get villa;

  /// No description provided for @singleFamilyHome.
  ///
  /// In en, this message translates to:
  /// **'Single Family Home'**
  String get singleFamilyHome;

  /// No description provided for @digitalClaimRequest.
  ///
  /// In en, this message translates to:
  /// **'Digital Claim Request'**
  String get digitalClaimRequest;

  /// No description provided for @requiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get requiredDocuments;

  /// No description provided for @vehicleRegistrationDocument.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration (Grey Card)'**
  String get vehicleRegistrationDocument;

  /// No description provided for @friendlyConstatOptional.
  ///
  /// In en, this message translates to:
  /// **'Friendly Constat (Optional)'**
  String get friendlyConstatOptional;

  /// No description provided for @damagePhotosCount.
  ///
  /// In en, this message translates to:
  /// **'Damage Photos ({count}/4)'**
  String damagePhotosCount(int count);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @carPhotoInstructions.
  ///
  /// In en, this message translates to:
  /// **'Take photos of the car from 4 different angles (front, back, right, left)'**
  String get carPhotoInstructions;

  /// No description provided for @accidentInformation.
  ///
  /// In en, this message translates to:
  /// **'Accident Information'**
  String get accidentInformation;

  /// No description provided for @relatedPolicy.
  ///
  /// In en, this message translates to:
  /// **'Related Policy'**
  String get relatedPolicy;

  /// No description provided for @cityNeighborhoodStreet.
  ///
  /// In en, this message translates to:
  /// **'City, Neighborhood, Street...'**
  String get cityNeighborhoodStreet;

  /// No description provided for @pleaseEnterAccidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter the accident location'**
  String get pleaseEnterAccidentLocation;

  /// No description provided for @pleaseEnterDetailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Please write a detailed description (at least 20 characters)'**
  String get pleaseEnterDetailedDescription;

  /// No description provided for @explainWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Explain what happened in detail...'**
  String get explainWhatHappened;

  /// No description provided for @claimTrackingStages.
  ///
  /// In en, this message translates to:
  /// **'Claim Tracking Stages'**
  String get claimTrackingStages;

  /// No description provided for @fileReceivedAfterUpload.
  ///
  /// In en, this message translates to:
  /// **'File Received (After Upload)'**
  String get fileReceivedAfterUpload;

  /// No description provided for @expertAssignedDetails.
  ///
  /// In en, this message translates to:
  /// **'Expert Assigned (Shows expert name, phone, and location)'**
  String get expertAssignedDetails;

  /// No description provided for @pleaseUploadRequiredDocs.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least the driving license and grey card'**
  String get pleaseUploadRequiredDocs;

  /// No description provided for @uploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Uploaded ✓'**
  String get uploadedSuccessfully;

  /// No description provided for @max4DamagePhotos.
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 damage photos'**
  String get max4DamagePhotos;

  /// No description provided for @claimReceivedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Claim request received successfully ✓'**
  String get claimReceivedSuccessfully;

  /// No description provided for @errorWithParam.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithParam(String error);

  /// No description provided for @fileSizeExceedsLimit.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds the 5MB limit'**
  String get fileSizeExceedsLimit;

  /// No description provided for @pleaseUploadRequiredDocsForReassessment.
  ///
  /// In en, this message translates to:
  /// **'Please upload the required documents for reassessment - {planName}'**
  String pleaseUploadRequiredDocsForReassessment(String planName);

  /// No description provided for @maxFileSize5MB.
  ///
  /// In en, this message translates to:
  /// **'Maximum file size is 5MB (PDF or images)'**
  String get maxFileSize5MB;

  /// No description provided for @uploadedPreviouslyChooseToEdit.
  ///
  /// In en, this message translates to:
  /// **'Uploaded previously, choose a file to edit'**
  String get uploadedPreviouslyChooseToEdit;

  /// No description provided for @pleaseChooseAFile.
  ///
  /// In en, this message translates to:
  /// **'Please choose a file'**
  String get pleaseChooseAFile;

  /// No description provided for @saveAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Save & Resubmit'**
  String get saveAndResubmit;

  /// No description provided for @modifyDocumentsRequest.
  ///
  /// In en, this message translates to:
  /// **'Document Modification Request'**
  String get modifyDocumentsRequest;

  /// No description provided for @pleaseReuploadDocsAsRequested.
  ///
  /// In en, this message translates to:
  /// **'Please re-upload or modify the required documents as requested by administration.'**
  String get pleaseReuploadDocsAsRequested;

  /// No description provided for @editAndResubmitDocs.
  ///
  /// In en, this message translates to:
  /// **'Edit & Resubmit Documents'**
  String get editAndResubmitDocs;

  /// No description provided for @sosEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency at the push of a button'**
  String get sosEmergencyTitle;

  /// No description provided for @sosServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Our digital app connects you instantly to the largest network of dépannage services and certified workshops in your province for fast and safe intervention.'**
  String get sosServiceSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get done;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @directCall.
  ///
  /// In en, this message translates to:
  /// **'Direct Call'**
  String get directCall;

  /// No description provided for @wilayaLabel.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get wilayaLabel;

  /// No description provided for @specialtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialtyLabel;

  /// No description provided for @failedToLoadGarages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load garages. Check your connection.'**
  String get failedToLoadGarages;

  /// No description provided for @dummyEmergencyStation.
  ///
  /// In en, this message translates to:
  /// **'Emergency Station — Abu Khalid'**
  String get dummyEmergencyStation;

  /// No description provided for @dummyTowingService.
  ///
  /// In en, this message translates to:
  /// **'Towing & Recovery'**
  String get dummyTowingService;

  /// No description provided for @wilaya1.
  ///
  /// In en, this message translates to:
  /// **'Adrar'**
  String get wilaya1;

  /// No description provided for @wilaya2.
  ///
  /// In en, this message translates to:
  /// **'Chlef'**
  String get wilaya2;

  /// No description provided for @wilaya3.
  ///
  /// In en, this message translates to:
  /// **'Laghouat'**
  String get wilaya3;

  /// No description provided for @wilaya4.
  ///
  /// In en, this message translates to:
  /// **'Oum El Bouaghi'**
  String get wilaya4;

  /// No description provided for @wilaya5.
  ///
  /// In en, this message translates to:
  /// **'Batna'**
  String get wilaya5;

  /// No description provided for @wilaya6.
  ///
  /// In en, this message translates to:
  /// **'Bejaia'**
  String get wilaya6;

  /// No description provided for @wilaya7.
  ///
  /// In en, this message translates to:
  /// **'Biskra'**
  String get wilaya7;

  /// No description provided for @wilaya8.
  ///
  /// In en, this message translates to:
  /// **'Bechar'**
  String get wilaya8;

  /// No description provided for @wilaya9.
  ///
  /// In en, this message translates to:
  /// **'Blida'**
  String get wilaya9;

  /// No description provided for @wilaya10.
  ///
  /// In en, this message translates to:
  /// **'Bouira'**
  String get wilaya10;

  /// No description provided for @wilaya11.
  ///
  /// In en, this message translates to:
  /// **'Tamanrasset'**
  String get wilaya11;

  /// No description provided for @wilaya12.
  ///
  /// In en, this message translates to:
  /// **'Tebessa'**
  String get wilaya12;

  /// No description provided for @wilaya13.
  ///
  /// In en, this message translates to:
  /// **'Tlemcen'**
  String get wilaya13;

  /// No description provided for @wilaya14.
  ///
  /// In en, this message translates to:
  /// **'Tiaret'**
  String get wilaya14;

  /// No description provided for @wilaya15.
  ///
  /// In en, this message translates to:
  /// **'Tizi Ouzou'**
  String get wilaya15;

  /// No description provided for @wilaya16.
  ///
  /// In en, this message translates to:
  /// **'Algiers'**
  String get wilaya16;

  /// No description provided for @wilaya17.
  ///
  /// In en, this message translates to:
  /// **'Djelfa'**
  String get wilaya17;

  /// No description provided for @wilaya18.
  ///
  /// In en, this message translates to:
  /// **'Jijel'**
  String get wilaya18;

  /// No description provided for @wilaya19.
  ///
  /// In en, this message translates to:
  /// **'Setif'**
  String get wilaya19;

  /// No description provided for @wilaya20.
  ///
  /// In en, this message translates to:
  /// **'Saida'**
  String get wilaya20;

  /// No description provided for @wilaya21.
  ///
  /// In en, this message translates to:
  /// **'Skikda'**
  String get wilaya21;

  /// No description provided for @wilaya22.
  ///
  /// In en, this message translates to:
  /// **'Sidi Bel Abbes'**
  String get wilaya22;

  /// No description provided for @wilaya23.
  ///
  /// In en, this message translates to:
  /// **'Annaba'**
  String get wilaya23;

  /// No description provided for @wilaya24.
  ///
  /// In en, this message translates to:
  /// **'Guelma'**
  String get wilaya24;

  /// No description provided for @wilaya25.
  ///
  /// In en, this message translates to:
  /// **'Constantine'**
  String get wilaya25;

  /// No description provided for @wilaya26.
  ///
  /// In en, this message translates to:
  /// **'Medea'**
  String get wilaya26;

  /// No description provided for @wilaya27.
  ///
  /// In en, this message translates to:
  /// **'Mostaganem'**
  String get wilaya27;

  /// No description provided for @wilaya28.
  ///
  /// In en, this message translates to:
  /// **'M\'Sila'**
  String get wilaya28;

  /// No description provided for @wilaya29.
  ///
  /// In en, this message translates to:
  /// **'Mascara'**
  String get wilaya29;

  /// No description provided for @wilaya30.
  ///
  /// In en, this message translates to:
  /// **'Ouargla'**
  String get wilaya30;

  /// No description provided for @wilaya31.
  ///
  /// In en, this message translates to:
  /// **'Oran'**
  String get wilaya31;

  /// No description provided for @wilaya32.
  ///
  /// In en, this message translates to:
  /// **'El Bayadh'**
  String get wilaya32;

  /// No description provided for @wilaya33.
  ///
  /// In en, this message translates to:
  /// **'Illizi'**
  String get wilaya33;

  /// No description provided for @wilaya34.
  ///
  /// In en, this message translates to:
  /// **'Bordj Bou Arreridj'**
  String get wilaya34;

  /// No description provided for @wilaya35.
  ///
  /// In en, this message translates to:
  /// **'Boumerdes'**
  String get wilaya35;

  /// No description provided for @wilaya36.
  ///
  /// In en, this message translates to:
  /// **'El Tarf'**
  String get wilaya36;

  /// No description provided for @wilaya37.
  ///
  /// In en, this message translates to:
  /// **'Tindouf'**
  String get wilaya37;

  /// No description provided for @wilaya38.
  ///
  /// In en, this message translates to:
  /// **'Tissemsilt'**
  String get wilaya38;

  /// No description provided for @wilaya39.
  ///
  /// In en, this message translates to:
  /// **'El Oued'**
  String get wilaya39;

  /// No description provided for @wilaya40.
  ///
  /// In en, this message translates to:
  /// **'Khenchela'**
  String get wilaya40;

  /// No description provided for @wilaya41.
  ///
  /// In en, this message translates to:
  /// **'Souk Ahras'**
  String get wilaya41;

  /// No description provided for @wilaya42.
  ///
  /// In en, this message translates to:
  /// **'Tipaza'**
  String get wilaya42;

  /// No description provided for @wilaya43.
  ///
  /// In en, this message translates to:
  /// **'Mila'**
  String get wilaya43;

  /// No description provided for @wilaya44.
  ///
  /// In en, this message translates to:
  /// **'Ain Defla'**
  String get wilaya44;

  /// No description provided for @wilaya45.
  ///
  /// In en, this message translates to:
  /// **'Naama'**
  String get wilaya45;

  /// No description provided for @wilaya46.
  ///
  /// In en, this message translates to:
  /// **'Ain Temouchent'**
  String get wilaya46;

  /// No description provided for @wilaya47.
  ///
  /// In en, this message translates to:
  /// **'Ghardaia'**
  String get wilaya47;

  /// No description provided for @wilaya48.
  ///
  /// In en, this message translates to:
  /// **'Relizane'**
  String get wilaya48;

  /// No description provided for @uploadGrayCardSuccess.
  ///
  /// In en, this message translates to:
  /// **'Gray Card Uploaded'**
  String get uploadGrayCardSuccess;

  /// No description provided for @grayCardImage.
  ///
  /// In en, this message translates to:
  /// **'Gray Card Image'**
  String get grayCardImage;

  /// No description provided for @exampleCarValue.
  ///
  /// In en, this message translates to:
  /// **'Example: 2000000'**
  String get exampleCarValue;

  /// No description provided for @enterCarValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter the car value'**
  String get enterCarValue;

  /// No description provided for @estimatedPremium.
  ///
  /// In en, this message translates to:
  /// **'Estimated Premium (0.4%): {amount} DZD'**
  String estimatedPremium(String amount);

  /// No description provided for @insuranceDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurance Duration'**
  String get insuranceDurationLabel;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get sixMonths;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get oneYear;

  /// No description provided for @selectInsuranceDuration.
  ///
  /// In en, this message translates to:
  /// **'Please select insurance duration'**
  String get selectInsuranceDuration;

  /// No description provided for @equipmentValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment Value (DZD)'**
  String get equipmentValueLabel;

  /// No description provided for @goodsValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Goods Value (DZD)'**
  String get goodsValueLabel;

  /// No description provided for @artisan.
  ///
  /// In en, this message translates to:
  /// **'Artisan / Craftsman'**
  String get artisan;

  /// No description provided for @registrationNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Professional Registration Number'**
  String get registrationNumberLabel;

  /// No description provided for @travelDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Destination'**
  String get travelDestinationLabel;

  /// No description provided for @exampleDestination.
  ///
  /// In en, this message translates to:
  /// **'Example: France, Tunisia, Saudi Arabia'**
  String get exampleDestination;

  /// No description provided for @enterDestination.
  ///
  /// In en, this message translates to:
  /// **'Please enter destination'**
  String get enterDestination;

  /// No description provided for @travelDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Duration (days)'**
  String get travelDurationLabel;

  /// No description provided for @enterDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter duration'**
  String get enterDuration;

  /// No description provided for @individualHouse.
  ///
  /// In en, this message translates to:
  /// **'Individual House'**
  String get individualHouse;

  /// No description provided for @selectResidenceType.
  ///
  /// In en, this message translates to:
  /// **'Please select residence type'**
  String get selectResidenceType;

  /// No description provided for @fullAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddressLabel;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get enterAddress;

  /// No description provided for @enterGoodsNature.
  ///
  /// In en, this message translates to:
  /// **'Please enter goods nature'**
  String get enterGoodsNature;

  /// No description provided for @cargoGoodsValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Cargo Goods Value (DZD)'**
  String get cargoGoodsValueLabel;

  /// No description provided for @enterCargoValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter the value'**
  String get enterCargoValue;

  /// No description provided for @enterRoute.
  ///
  /// In en, this message translates to:
  /// **'Please enter route'**
  String get enterRoute;

  /// No description provided for @facilityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Facility / Farm Type'**
  String get facilityTypeLabel;

  /// No description provided for @enterFacilityType.
  ///
  /// In en, this message translates to:
  /// **'Please enter facility type'**
  String get enterFacilityType;

  /// No description provided for @facilitySizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Facility Size / Area'**
  String get facilitySizeLabel;

  /// No description provided for @exampleFacilitySize.
  ///
  /// In en, this message translates to:
  /// **'Example: 500 sqm or 10 hectares'**
  String get exampleFacilitySize;

  /// No description provided for @enterFacilitySize.
  ///
  /// In en, this message translates to:
  /// **'Please enter facility size'**
  String get enterFacilitySize;

  /// No description provided for @takafulPackage.
  ///
  /// In en, this message translates to:
  /// **'Takaful Package'**
  String get takafulPackage;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @awaitingFinalApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting final approval'**
  String get awaitingFinalApproval;

  /// No description provided for @quoteRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Quote Request Details'**
  String get quoteRequestDetails;

  /// No description provided for @chooseService.
  ///
  /// In en, this message translates to:
  /// **'Choose Service'**
  String get chooseService;

  /// No description provided for @serviceChosen.
  ///
  /// In en, this message translates to:
  /// **'Chosen Service'**
  String get serviceChosen;

  /// No description provided for @submitQuoteRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Quote Request'**
  String get submitQuoteRequest;

  /// No description provided for @donationRate.
  ///
  /// In en, this message translates to:
  /// **'Donation Rate'**
  String get donationRate;

  /// No description provided for @settlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlement;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @requestData.
  ///
  /// In en, this message translates to:
  /// **'Request Data'**
  String get requestData;

  /// No description provided for @alIttihadTakaful.
  ///
  /// In en, this message translates to:
  /// **'Al Ittihad - Comprehensive Takaful'**
  String get alIttihadTakaful;

  /// No description provided for @alRafikPlan.
  ///
  /// In en, this message translates to:
  /// **'Al-Rafik'**
  String get alRafikPlan;

  /// No description provided for @rafikInsuranceIttihad.
  ///
  /// In en, this message translates to:
  /// **'Al-Rafik Insurance from Al Ittihad'**
  String get rafikInsuranceIttihad;

  /// No description provided for @pleaseCompleteData.
  ///
  /// In en, this message translates to:
  /// **'Please complete data (Driver Age + Grey Card Image)'**
  String get pleaseCompleteData;

  /// No description provided for @requiredInfoToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Information required to subscribe:'**
  String get requiredInfoToSubscribe;

  /// No description provided for @greyCardUploaded.
  ///
  /// In en, this message translates to:
  /// **'Grey Card Uploaded'**
  String get greyCardUploaded;

  /// No description provided for @legalCompliancePortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Legal and Sharia Compliance Portal'**
  String get legalCompliancePortalSubtitle;

  /// No description provided for @wakalaPrincipleDesc.
  ///
  /// In en, this message translates to:
  /// **'The company is an agent managing the fund for a known fee'**
  String get wakalaPrincipleDesc;

  /// No description provided for @shariaOversightTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharia Oversight'**
  String get shariaOversightTitle;

  /// No description provided for @shariaOversightDesc.
  ///
  /// In en, this message translates to:
  /// **'No contract is issued without the National Sharia Board visa'**
  String get shariaOversightDesc;

  /// No description provided for @subscribersFundTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribers Fund'**
  String get subscribersFundTitle;

  /// No description provided for @subscribersFundDesc.
  ///
  /// In en, this message translates to:
  /// **'Funds are used exclusively to compensate those affected'**
  String get subscribersFundDesc;

  /// No description provided for @socialTakafulTitle.
  ///
  /// In en, this message translates to:
  /// **'Social Takaful'**
  String get socialTakafulTitle;

  /// No description provided for @socialTakafulDesc.
  ///
  /// In en, this message translates to:
  /// **'The goal is cooperation, not profit'**
  String get socialTakafulDesc;

  /// No description provided for @regulatoryLawsTitle.
  ///
  /// In en, this message translates to:
  /// **'Regulatory Laws'**
  String get regulatoryLawsTitle;

  /// No description provided for @lawOrder9507.
  ///
  /// In en, this message translates to:
  /// **'Order No. 95-07 (amended and supplemented)'**
  String get lawOrder9507;

  /// No description provided for @lawDecree2181.
  ///
  /// In en, this message translates to:
  /// **'Executive Decree No. 21-81'**
  String get lawDecree2181;

  /// No description provided for @lawFinanceMinistry2021.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Finance Decision (2021)'**
  String get lawFinanceMinistry2021;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @myPersonalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Personal Documents'**
  String get myPersonalDocuments;

  /// No description provided for @personalDocsViewOnly.
  ///
  /// In en, this message translates to:
  /// **'These are the documents you uploaded during registration. View only.'**
  String get personalDocsViewOnly;

  /// No description provided for @confirmRefuseOffer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to refuse this offer? This action cannot be undone.'**
  String get confirmRefuseOffer;

  /// No description provided for @aiTotalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get aiTotalRequests;

  /// No description provided for @aiApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get aiApproved;

  /// No description provided for @aiSurplusNav.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get aiSurplusNav;

  /// No description provided for @aiPaidPolicies.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get aiPaidPolicies;

  /// No description provided for @aiRejectedPolicies.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get aiRejectedPolicies;

  /// No description provided for @aiDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive takaful for individuals and institutions'**
  String get aiDashboardSubtitle;

  /// No description provided for @aiPolicy.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get aiPolicy;

  /// No description provided for @aiNewPolicyRequest.
  ///
  /// In en, this message translates to:
  /// **'New policy request from {applicant}'**
  String aiNewPolicyRequest(Object applicant);

  /// No description provided for @aiNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests at the moment'**
  String get aiNoRequests;

  /// No description provided for @aiLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String aiLoadError(Object error);

  /// No description provided for @aiClaimsVsSurplusTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count} policy'**
  String aiClaimsVsSurplusTooltip(Object count);

  /// No description provided for @aiMonthlySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscriptions'**
  String get aiMonthlySubscriptions;

  /// No description provided for @aiQuoteRequest.
  ///
  /// In en, this message translates to:
  /// **'Quote Request'**
  String get aiQuoteRequest;

  /// No description provided for @aiMonthlyRequests.
  ///
  /// In en, this message translates to:
  /// **'Monthly Requests'**
  String get aiMonthlyRequests;

  /// No description provided for @aiStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Request Status Distribution'**
  String get aiStatusDistribution;

  /// No description provided for @aiPaidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get aiPaidStatus;

  /// No description provided for @aiRequestTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count} request'**
  String aiRequestTooltip(Object count);

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @aiRoadsideTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadside Assistance & Workshops'**
  String get aiRoadsideTitle;

  /// No description provided for @aiTowingService.
  ///
  /// In en, this message translates to:
  /// **'Express Recovery Towing — Available 24/7'**
  String get aiTowingService;

  /// No description provided for @aiEmergencyCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Call immediately for urgent assistance 24/7'**
  String get aiEmergencyCallSubtitle;

  /// No description provided for @aiWorkshopNakhba.
  ///
  /// In en, this message translates to:
  /// **'Al-Nakhba Workshop — Ouled Fayet, Algiers'**
  String get aiWorkshopNakhba;

  /// No description provided for @aiWorkshopAmane.
  ///
  /// In en, this message translates to:
  /// **'Al-Aman Workshop — Bab Ezzouar, Algiers'**
  String get aiWorkshopAmane;

  /// No description provided for @aiCertifiedWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Certified Mechanic Workshops'**
  String get aiCertifiedWorkshops;

  /// No description provided for @aiTowingServices.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Towing Services'**
  String get aiTowingServices;

  /// No description provided for @aiEmergency3030.
  ///
  /// In en, this message translates to:
  /// **'Emergency 3030'**
  String get aiEmergency3030;

  /// No description provided for @aiIttihaddTowing.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Safe Towing — National Coverage'**
  String get aiIttihaddTowing;

  /// No description provided for @aiHotlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Unified Emergency Hotline'**
  String get aiHotlineTitle;

  /// No description provided for @aiWorkshopPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String aiWorkshopPhone(Object phone);

  /// No description provided for @aiPoliciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance Policy Requests'**
  String get aiPoliciesTitle;

  /// No description provided for @aiPoliciesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review, modify and audit incoming subscription requests'**
  String get aiPoliciesSubtitle;

  /// No description provided for @aiManagePolicies.
  ///
  /// In en, this message translates to:
  /// **'Manage Insurance Policies'**
  String get aiManagePolicies;

  /// No description provided for @aiCompanyPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Algeria'**
  String get aiCompanyPortalTitle;

  /// No description provided for @aiNewInsuranceRequests.
  ///
  /// In en, this message translates to:
  /// **'New Insurance Requests'**
  String get aiNewInsuranceRequests;

  /// No description provided for @aiSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by client name or ID number...'**
  String get aiSearchHint;

  /// No description provided for @aiLoadErrorShort.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String aiLoadErrorShort(Object error);

  /// No description provided for @aiSubscriberRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Request Details'**
  String get aiSubscriberRequestDetails;

  /// No description provided for @aiAlgeriaUnitedFull.
  ///
  /// In en, this message translates to:
  /// **'Algeria United (Al-Ittihad)'**
  String get aiAlgeriaUnitedFull;

  /// No description provided for @aiRequestCode.
  ///
  /// In en, this message translates to:
  /// **'Request Code: {code}'**
  String aiRequestCode(Object code);

  /// No description provided for @aiSubscriberPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Personal Information'**
  String get aiSubscriberPersonalInfo;

  /// No description provided for @aiIdentityAndContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Verified identity and contact information'**
  String get aiIdentityAndContactInfo;

  /// No description provided for @aiServiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Requested Service Details'**
  String get aiServiceDetails;

  /// No description provided for @aiUnspecifiedService.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Service'**
  String get aiUnspecifiedService;

  /// No description provided for @aiEstimatedAmountAndDate.
  ///
  /// In en, this message translates to:
  /// **'Estimated Amount and Date'**
  String get aiEstimatedAmountAndDate;

  /// No description provided for @aiAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get aiAmountLabel;

  /// No description provided for @aiRequestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date:'**
  String get aiRequestDate;

  /// No description provided for @aiAttachedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attached Documents'**
  String get aiAttachedDocuments;

  /// No description provided for @aiNoDocumentsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No documents uploaded.'**
  String get aiNoDocumentsUploaded;

  /// No description provided for @aiClickToPreview.
  ///
  /// In en, this message translates to:
  /// **'Tap to preview'**
  String get aiClickToPreview;

  /// No description provided for @aiDocumentOpenError.
  ///
  /// In en, this message translates to:
  /// **'Error opening document: {error}'**
  String aiDocumentOpenError(Object error);

  /// No description provided for @aiFinalQuoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Final Quote (DZD):'**
  String get aiFinalQuoteLabel;

  /// No description provided for @aiFinalQuoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the final quote amount'**
  String get aiFinalQuoteHint;

  /// No description provided for @aiOperatorDecisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator Decision & Notes:'**
  String get aiOperatorDecisionLabel;

  /// No description provided for @aiDecisionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Write acceptance or rejection notes here...'**
  String get aiDecisionNotesHint;

  /// No description provided for @aiWriteReasonNote.
  ///
  /// In en, this message translates to:
  /// **'Please write the reason in the notes'**
  String get aiWriteReasonNote;

  /// No description provided for @aiValidQuoteRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quote before accepting'**
  String get aiValidQuoteRequired;

  /// No description provided for @aiOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Promotional Offers'**
  String get aiOffersTitle;

  /// No description provided for @aiAddOffer.
  ///
  /// In en, this message translates to:
  /// **'Add New Promotional Offer'**
  String get aiAddOffer;

  /// No description provided for @aiEditOffer.
  ///
  /// In en, this message translates to:
  /// **'Edit Offer Details'**
  String get aiEditOffer;

  /// No description provided for @aiOfferName.
  ///
  /// In en, this message translates to:
  /// **'Promotional Offer Name'**
  String get aiOfferName;

  /// No description provided for @aiPremiumValue.
  ///
  /// In en, this message translates to:
  /// **'Subscription Premium (DZD)'**
  String get aiPremiumValue;

  /// No description provided for @aiCoverageLimit.
  ///
  /// In en, this message translates to:
  /// **'Financial Coverage Limit for Compensations'**
  String get aiCoverageLimit;

  /// No description provided for @aiTabarruRate.
  ///
  /// In en, this message translates to:
  /// **'Donation Fund Rate (%)'**
  String get aiTabarruRate;

  /// No description provided for @aiSurplusRate.
  ///
  /// In en, this message translates to:
  /// **'Distributed Surplus Rate (%)'**
  String get aiSurplusRate;

  /// No description provided for @aiClaimsDurationDays.
  ///
  /// In en, this message translates to:
  /// **'Claims Settlement Duration (days)'**
  String get aiClaimsDurationDays;

  /// No description provided for @aiIconCode.
  ///
  /// In en, this message translates to:
  /// **'Promotional Offer Icon'**
  String get aiIconCode;

  /// No description provided for @aiIconShield.
  ///
  /// In en, this message translates to:
  /// **'Protection Shield'**
  String get aiIconShield;

  /// No description provided for @aiIconVerified.
  ///
  /// In en, this message translates to:
  /// **'Certified & Verified'**
  String get aiIconVerified;

  /// No description provided for @aiIconRafik.
  ///
  /// In en, this message translates to:
  /// **'The Assistant Companion (Rafik)'**
  String get aiIconRafik;

  /// No description provided for @aiBestValueOffer.
  ///
  /// In en, this message translates to:
  /// **'Recommended Offer (Best Value)'**
  String get aiBestValueOffer;

  /// No description provided for @aiSaveOffer.
  ///
  /// In en, this message translates to:
  /// **'Save Promotional Offer'**
  String get aiSaveOffer;

  /// No description provided for @aiOfferSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promotional offer saved successfully'**
  String get aiOfferSavedSuccess;

  /// No description provided for @aiFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required and binding for the operator'**
  String get aiFieldRequired;

  /// No description provided for @aiDeleteOffer.
  ///
  /// In en, this message translates to:
  /// **'Delete Offer'**
  String get aiDeleteOffer;

  /// No description provided for @aiConfirmDeleteOffer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this offer?'**
  String get aiConfirmDeleteOffer;

  /// No description provided for @aiOfferDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer deleted successfully'**
  String get aiOfferDeletedSuccess;

  /// No description provided for @aiOfferSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String aiOfferSaveError(Object error);

  /// No description provided for @aiOfferUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating: {error}'**
  String aiOfferUpdateError(Object error);

  /// No description provided for @aiOfferDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String aiOfferDeleteError(Object error);

  /// No description provided for @aiOfferMarkedBestValue.
  ///
  /// In en, this message translates to:
  /// **'Offer marked as best value'**
  String get aiOfferMarkedBestValue;

  /// No description provided for @aiOfferUnmarkedBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value mark removed'**
  String get aiOfferUnmarkedBestValue;

  /// No description provided for @aiTabarruSuggestedRate.
  ///
  /// In en, this message translates to:
  /// **'Suggested Donation Rate for Subscriber'**
  String get aiTabarruSuggestedRate;

  /// No description provided for @aiClaimsDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String aiClaimsDurationValue(Object count);

  /// No description provided for @aiGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String aiGenericError(Object error);

  /// No description provided for @aiOperatorName.
  ///
  /// In en, this message translates to:
  /// **'System Operator'**
  String get aiOperatorName;

  /// No description provided for @aiSurplusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Surplus Distribution'**
  String get aiSurplusDistribution;

  /// No description provided for @aiQuarterlyDistributionLog.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Distribution Log'**
  String get aiQuarterlyDistributionLog;

  /// No description provided for @aiNoSurplusData.
  ///
  /// In en, this message translates to:
  /// **'No surplus data available'**
  String get aiNoSurplusData;

  /// No description provided for @aiPolicyholdersSurplus.
  ///
  /// In en, this message translates to:
  /// **'Policyholders Surplus (90%)'**
  String get aiPolicyholdersSurplus;

  /// No description provided for @aiManagementShare.
  ///
  /// In en, this message translates to:
  /// **'Management Company Share (10%)'**
  String get aiManagementShare;

  /// No description provided for @aiSurplusAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Surplus Analytics'**
  String get aiSurplusAnalytics;

  /// No description provided for @aiTotalCoopInsuranceSurplus.
  ///
  /// In en, this message translates to:
  /// **'Total Distributed Cooperative Insurance Surplus'**
  String get aiTotalCoopInsuranceSurplus;

  /// No description provided for @aiNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Insurance Notifications'**
  String get aiNotificationsTitle;

  /// No description provided for @aiMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get aiMarkAllRead;

  /// No description provided for @aiNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications at the moment'**
  String get aiNoNotifications;

  /// No description provided for @aiNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get aiNow;

  /// No description provided for @aiMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String aiMinutesAgo(Object count);

  /// No description provided for @aiHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String aiHoursAgo(Object count);

  /// No description provided for @aiDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String aiDaysAgo(Object count);

  /// No description provided for @aiNotificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications: {error}'**
  String aiNotificationsLoadError(Object error);

  /// No description provided for @withdrawRequestUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request is under review'**
  String get withdrawRequestUnderReview;

  /// No description provided for @withdrawAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount to withdraw'**
  String get withdrawAmountHint;

  /// No description provided for @ccpNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Current Account Number (CCP)'**
  String get ccpNumberHint;

  /// No description provided for @withdrawSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'All withdrawals are reviewed by the financial system to ensure compliance with Decree 21-81.'**
  String get withdrawSecurityNote;

  /// No description provided for @adminResetSystemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to wipe all data? All users (except admins), policies, claims, and logs will be permanently deleted. This action cannot be undone.'**
  String get adminResetSystemConfirm;

  /// No description provided for @adminWipeAll.
  ///
  /// In en, this message translates to:
  /// **'Wipe All'**
  String get adminWipeAll;

  /// No description provided for @adminResetSystemSuccess.
  ///
  /// In en, this message translates to:
  /// **'System reset completed successfully.'**
  String get adminResetSystemSuccess;

  /// No description provided for @adminDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get adminDangerZone;

  /// No description provided for @adminResetSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset System (Full Wipe)'**
  String get adminResetSystemTitle;

  /// No description provided for @noPlansFound.
  ///
  /// In en, this message translates to:
  /// **'No plans available at the moment'**
  String get noPlansFound;

  /// No description provided for @adminOperatorCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator / Company'**
  String get adminOperatorCompanyLabel;

  /// No description provided for @adminPlanCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Code (e.g. TRANSPORT_PRO)'**
  String get adminPlanCodeLabel;

  /// No description provided for @adminPlanNameArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Name (Arabic)'**
  String get adminPlanNameArabicLabel;

  /// No description provided for @adminNameArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Name in Arabic'**
  String get adminNameArabicHint;

  /// No description provided for @adminStartingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Price (DZD)'**
  String get adminStartingPriceLabel;

  /// No description provided for @adminDisplayAndStyleSection.
  ///
  /// In en, this message translates to:
  /// **'Display & Icon'**
  String get adminDisplayAndStyleSection;

  /// No description provided for @adminIconTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon Type'**
  String get adminIconTypeLabel;

  /// No description provided for @adminShortDescriptionArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Description (Arabic)'**
  String get adminShortDescriptionArabicLabel;

  /// No description provided for @adminPlanDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Plan description...'**
  String get adminPlanDescriptionHint;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @noNotificationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No notifications at the moment'**
  String get noNotificationsAvailable;

  /// No description provided for @mockClient1.
  ///
  /// In en, this message translates to:
  /// **'Ahmed Mohamed'**
  String get mockClient1;

  /// No description provided for @mockClient2.
  ///
  /// In en, this message translates to:
  /// **'Omar Khaled'**
  String get mockClient2;

  /// No description provided for @adminTotalSubscriptionsCollected.
  ///
  /// In en, this message translates to:
  /// **'Total subscriptions collected'**
  String get adminTotalSubscriptionsCollected;

  /// No description provided for @adminPolicyDistribution.
  ///
  /// In en, this message translates to:
  /// **'Policy Distribution'**
  String get adminPolicyDistribution;

  /// No description provided for @categoryProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get categoryProperties;

  /// No description provided for @adminSalesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales List'**
  String get adminSalesListTitle;

  /// No description provided for @adminNoSalesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No sales registered at the moment'**
  String get adminNoSalesRegistered;

  /// No description provided for @paymentReceiptLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get paymentReceiptLabel;

  /// No description provided for @noDocumentsAvailableForRequest.
  ///
  /// In en, this message translates to:
  /// **'No documents available for this request.'**
  String get noDocumentsAvailableForRequest;

  /// No description provided for @chooseDocumentToPreview.
  ///
  /// In en, this message translates to:
  /// **'Select document to preview'**
  String get chooseDocumentToPreview;

  /// No description provided for @algeriaUnitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria United'**
  String get algeriaUnitedTitle;

  /// No description provided for @takafulForIndividualsAndCompanies.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Takaful for individuals and companies'**
  String get takafulForIndividualsAndCompanies;

  /// No description provided for @newPolicyRequestFrom.
  ///
  /// In en, this message translates to:
  /// **'New policy request from {name}'**
  String newPolicyRequestFrom(Object name);

  /// No description provided for @errorLoadingDataWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingDataWithDetails(Object error);

  /// No description provided for @noRequestsCurrently.
  ///
  /// In en, this message translates to:
  /// **'No requests currently'**
  String get noRequestsCurrently;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get filterApproved;

  /// No description provided for @filterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filterPaid;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @alIttihadAlgerian.
  ///
  /// In en, this message translates to:
  /// **'Algerian Union'**
  String get alIttihadAlgerian;

  /// No description provided for @surplusDistributionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Surplus Distribution'**
  String get surplusDistributionSubtitle;

  /// No description provided for @quarterlyDistributionLog.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Distribution Log'**
  String get quarterlyDistributionLog;

  /// No description provided for @totalCooperativeInsuranceSurplus.
  ///
  /// In en, this message translates to:
  /// **'Total distributed cooperative insurance surplus'**
  String get totalCooperativeInsuranceSurplus;

  /// No description provided for @surplusChartAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Surplus Chart Analysis'**
  String get surplusChartAnalysis;

  /// No description provided for @noSurplusData.
  ///
  /// In en, this message translates to:
  /// **'No surplus data available'**
  String get noSurplusData;

  /// No description provided for @policyholdersSurplus90.
  ///
  /// In en, this message translates to:
  /// **'Policyholders surplus (90%)'**
  String get policyholdersSurplus90;

  /// No description provided for @managementFee10.
  ///
  /// In en, this message translates to:
  /// **'Management company fee (10%)'**
  String get managementFee10;

  /// No description provided for @insurancePoliciesRequests.
  ///
  /// In en, this message translates to:
  /// **'Insurance Policy Requests'**
  String get insurancePoliciesRequests;

  /// No description provided for @reviewAndAuditRequests.
  ///
  /// In en, this message translates to:
  /// **'Review, modify and audit incoming subscription requests'**
  String get reviewAndAuditRequests;

  /// No description provided for @searchByNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Search by client name or ID number...'**
  String get searchByNameOrId;

  /// No description provided for @newInsuranceRequests.
  ///
  /// In en, this message translates to:
  /// **'New insurance requests'**
  String get newInsuranceRequests;

  /// No description provided for @policyManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance Policy Management'**
  String get policyManagementSubtitle;

  /// No description provided for @offersManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Promotional Offers Management'**
  String get offersManagementSubtitle;

  /// No description provided for @errorDuringUpdate.
  ///
  /// In en, this message translates to:
  /// **'Error during update: {error}'**
  String errorDuringUpdate(String error);

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteOffer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this offer?'**
  String get confirmDeleteOffer;

  /// No description provided for @deleteOffer.
  ///
  /// In en, this message translates to:
  /// **'Delete offer'**
  String get deleteOffer;

  /// No description provided for @errorDuringDeletion.
  ///
  /// In en, this message translates to:
  /// **'Error during deletion: {error}'**
  String errorDuringDeletion(String error);

  /// No description provided for @editOfferData.
  ///
  /// In en, this message translates to:
  /// **'Edit offer data'**
  String get editOfferData;

  /// No description provided for @offerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Promotional offer name'**
  String get offerNameLabel;

  /// No description provided for @premiumAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Subscription premium amount (DZD)'**
  String get premiumAmountLabel;

  /// No description provided for @tabarruRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Proposed donation rate for subscriber'**
  String get tabarruRateLabel;

  /// No description provided for @coverageLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Financial coverage limit for compensations'**
  String get coverageLimitLabel;

  /// No description provided for @donationFundRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Donation fund rate (%)'**
  String get donationFundRateLabel;

  /// No description provided for @surplusDistributionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Distributed surplus rate (%)'**
  String get surplusDistributionRateLabel;

  /// No description provided for @claimSettlementDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Claim settlement duration (in days)'**
  String get claimSettlementDurationLabel;

  /// No description provided for @offerIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Promotional offer icon'**
  String get offerIconLabel;

  /// No description provided for @shieldProtection.
  ///
  /// In en, this message translates to:
  /// **'Shield Protection'**
  String get shieldProtection;

  /// No description provided for @verifiedCertified.
  ///
  /// In en, this message translates to:
  /// **'Verified and Certified'**
  String get verifiedCertified;

  /// No description provided for @rafikAssistant.
  ///
  /// In en, this message translates to:
  /// **'Rafik Assistant'**
  String get rafikAssistant;

  /// No description provided for @recommendedBestValueOffer.
  ///
  /// In en, this message translates to:
  /// **'Recommended offer (best value for subscriber)'**
  String get recommendedBestValueOffer;

  /// No description provided for @saveOfferData.
  ///
  /// In en, this message translates to:
  /// **'Save promotional offer data'**
  String get saveOfferData;

  /// No description provided for @errorDuringSave.
  ///
  /// In en, this message translates to:
  /// **'Error during save: {error}'**
  String errorDuringSave(String error);

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysUnit(int days);

  /// No description provided for @alIttihadInsuranceNotifications.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Insurance Notifications'**
  String get alIttihadInsuranceNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsCurrently.
  ///
  /// In en, this message translates to:
  /// **'No notifications currently'**
  String get noNotificationsCurrently;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get timeNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String timeMinutesAgo(Object count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String timeHoursAgo(Object count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(Object count);

  /// No description provided for @checkEmailForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm your account.'**
  String get checkEmailForConfirmation;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @accumulatedCommissionBalance.
  ///
  /// In en, this message translates to:
  /// **'Accumulated commission balance'**
  String get accumulatedCommissionBalance;

  /// No description provided for @requestProfitWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Request Profit Withdrawal'**
  String get requestProfitWithdrawal;

  /// No description provided for @companyUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified company'**
  String get companyUnspecified;

  /// No description provided for @statusApprovedSale.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApprovedSale;

  /// No description provided for @statusPaidSale.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaidSale;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @whyWeAreLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are we legal?'**
  String get whyWeAreLegalTitle;

  /// No description provided for @order9507.
  ///
  /// In en, this message translates to:
  /// **'Order 95-07'**
  String get order9507;

  /// No description provided for @order9507Desc.
  ///
  /// In en, this message translates to:
  /// **'The parent insurance law in Algeria'**
  String get order9507Desc;

  /// No description provided for @financeMinistryDecision.
  ///
  /// In en, this message translates to:
  /// **'Finance Ministry Decision 2021'**
  String get financeMinistryDecision;

  /// No description provided for @financeMinistryDecisionDesc.
  ///
  /// In en, this message translates to:
  /// **'Regulates contracts and surplus distribution'**
  String get financeMinistryDecisionDesc;

  /// No description provided for @nationalShariaBody.
  ///
  /// In en, this message translates to:
  /// **'National Sharia Authority'**
  String get nationalShariaBody;

  /// No description provided for @nationalShariaBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Sharia oversight on every contract'**
  String get nationalShariaBodyDesc;

  /// No description provided for @takafulProtectionCoopTitle.
  ///
  /// In en, this message translates to:
  /// **'Takaful.. Protection with the spirit of cooperation'**
  String get takafulProtectionCoopTitle;

  /// No description provided for @takafulPhilosophyDesc.
  ///
  /// In en, this message translates to:
  /// **'An Islamic insurance system based on the principle of solidarity — everyone contributes to a single fund to compensate those affected. The company is an agent managing the fund for a known fee, not the owner of the subscribers\' funds.'**
  String get takafulPhilosophyDesc;

  /// No description provided for @chipAgency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get chipAgency;

  /// No description provided for @chipShariaOversight.
  ///
  /// In en, this message translates to:
  /// **'Sharia Oversight'**
  String get chipShariaOversight;

  /// No description provided for @chipSubscribersFund.
  ///
  /// In en, this message translates to:
  /// **'Subscribers Fund'**
  String get chipSubscribersFund;

  /// No description provided for @chipSocialTakaful.
  ///
  /// In en, this message translates to:
  /// **'Social Takaful'**
  String get chipSocialTakaful;

  /// No description provided for @bestBadge.
  ///
  /// In en, this message translates to:
  /// **'⭐ Best'**
  String get bestBadge;

  /// No description provided for @settlementDuration.
  ///
  /// In en, this message translates to:
  /// **'Settlement Duration'**
  String get settlementDuration;

  /// No description provided for @coverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get coverageLabel;

  /// No description provided for @premiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumLabel;

  /// No description provided for @bestValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValueLabel;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'TameeniDz — All rights reserved © 2026'**
  String get footerCopyright;

  /// No description provided for @legalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// No description provided for @halalTakafulNotice.
  ///
  /// In en, this message translates to:
  /// **'100% halal Takaful insurance compliant with Islamic Sharia under the supervision of the National Sharia Authority.'**
  String get halalTakafulNotice;

  /// No description provided for @algeriaTakafulTitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful'**
  String get algeriaTakafulTitle;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(Object error);

  /// No description provided for @policyDocument.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get policyDocument;

  /// No description provided for @operatorSystemUser.
  ///
  /// In en, this message translates to:
  /// **'System Operator'**
  String get operatorSystemUser;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientLabel;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote Request'**
  String get requestQuote;

  /// No description provided for @requestInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance Request'**
  String get requestInsurance;

  /// No description provided for @requestClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim Request'**
  String get requestClaim;

  /// No description provided for @claimDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim Details'**
  String get claimDetailTitle;

  /// No description provided for @takafulPortal.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful Portal'**
  String get takafulPortal;

  /// No description provided for @ittihadPortal.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad Insurance Portal'**
  String get ittihadPortal;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updateSuccess;

  /// No description provided for @pleaseEnterExpertName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the expert name'**
  String get pleaseEnterExpertName;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid compensation amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @pleaseEnterRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Please write the rejection reason'**
  String get pleaseEnterRejectionReason;

  /// No description provided for @clientInfo.
  ///
  /// In en, this message translates to:
  /// **'Client Information'**
  String get clientInfo;

  /// No description provided for @defaultClientName.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get defaultClientName;

  /// No description provided for @requestTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Request type: {type}'**
  String requestTypeLabel(String type);

  /// No description provided for @submissionDate.
  ///
  /// In en, this message translates to:
  /// **'Submission date:'**
  String get submissionDate;

  /// No description provided for @incidentDate.
  ///
  /// In en, this message translates to:
  /// **'Incident date:'**
  String get incidentDate;

  /// No description provided for @incidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Incident location:'**
  String get incidentLocation;

  /// No description provided for @incidentDescription.
  ///
  /// In en, this message translates to:
  /// **'Incident Description'**
  String get incidentDescription;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @attachedDocumentsCount.
  ///
  /// In en, this message translates to:
  /// **'Attached Documents ({count})'**
  String attachedDocumentsCount(String count);

  /// No description provided for @claimProcessStages.
  ///
  /// In en, this message translates to:
  /// **'Claim Processing Stages'**
  String get claimProcessStages;

  /// No description provided for @assignExpert.
  ///
  /// In en, this message translates to:
  /// **'Assign Expert'**
  String get assignExpert;

  /// No description provided for @enterExpertNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the assigned expert name'**
  String get enterExpertNameHint;

  /// No description provided for @assignExpertAndStartInspection.
  ///
  /// In en, this message translates to:
  /// **'Assign Expert & Start Inspection'**
  String get assignExpertAndStartInspection;

  /// No description provided for @estimateDamageAmount.
  ///
  /// In en, this message translates to:
  /// **'Estimate Damage Amount (DZD)'**
  String get estimateDamageAmount;

  /// No description provided for @enterEstimatedAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the estimated damage amount'**
  String get enterEstimatedAmountHint;

  /// No description provided for @reviewNotes.
  ///
  /// In en, this message translates to:
  /// **'Review Notes'**
  String get reviewNotes;

  /// No description provided for @writeNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Write your notes about the file here...'**
  String get writeNotesHint;

  /// No description provided for @claimAccepted.
  ///
  /// In en, this message translates to:
  /// **'Claim Accepted'**
  String get claimAccepted;

  /// No description provided for @approvedAmount.
  ///
  /// In en, this message translates to:
  /// **'Approved Amount'**
  String get approvedAmount;

  /// No description provided for @compensationAmount.
  ///
  /// In en, this message translates to:
  /// **'Compensation amount:'**
  String get compensationAmount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notes;

  /// No description provided for @claimRejected.
  ///
  /// In en, this message translates to:
  /// **'Claim Rejected'**
  String get claimRejected;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notesLabel;

  /// No description provided for @rejectFile.
  ///
  /// In en, this message translates to:
  /// **'Reject File'**
  String get rejectFile;

  /// No description provided for @acceptAndIssueRepairOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept & Issue Repair Order'**
  String get acceptAndIssueRepairOrder;

  /// No description provided for @acceptCompensation.
  ///
  /// In en, this message translates to:
  /// **'Accept Compensation'**
  String get acceptCompensation;

  /// No description provided for @stageFileReceived.
  ///
  /// In en, this message translates to:
  /// **'File Received'**
  String get stageFileReceived;

  /// No description provided for @stageDocumentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Documents received'**
  String get stageDocumentsReceived;

  /// No description provided for @stageAssignExpert.
  ///
  /// In en, this message translates to:
  /// **'Assign Expert'**
  String get stageAssignExpert;

  /// No description provided for @stageDamageInspection.
  ///
  /// In en, this message translates to:
  /// **'Damage inspection expert'**
  String get stageDamageInspection;

  /// No description provided for @stageRepairOrder.
  ///
  /// In en, this message translates to:
  /// **'Repair Order'**
  String get stageRepairOrder;

  /// No description provided for @stageRepairDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct compensation & repair'**
  String get stageRepairDirect;

  /// No description provided for @statusPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPendingLabel;

  /// No description provided for @statusAcceptedLabel.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAcceptedLabel;

  /// No description provided for @statusRejectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejectedLabel;

  /// No description provided for @docDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get docDrivingLicense;

  /// No description provided for @docGreyCard.
  ///
  /// In en, this message translates to:
  /// **'Grey Card'**
  String get docGreyCard;

  /// No description provided for @docFriendlyInspection.
  ///
  /// In en, this message translates to:
  /// **'Friendly Inspection'**
  String get docFriendlyInspection;

  /// No description provided for @docRcCard.
  ///
  /// In en, this message translates to:
  /// **'RC Card'**
  String get docRcCard;

  /// No description provided for @docCarPhoto.
  ///
  /// In en, this message translates to:
  /// **'Car Photo {number}'**
  String docCarPhoto(String number);

  /// No description provided for @docDamagePhoto.
  ///
  /// In en, this message translates to:
  /// **'Damage Photo {number}'**
  String docDamagePhoto(String number);

  /// No description provided for @claimTypeAccident.
  ///
  /// In en, this message translates to:
  /// **'Traffic Accident'**
  String get claimTypeAccident;

  /// No description provided for @claimTypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Request'**
  String get claimTypeGeneral;

  /// No description provided for @claimTypeTheft.
  ///
  /// In en, this message translates to:
  /// **'Theft'**
  String get claimTypeTheft;

  /// No description provided for @claimTypeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get claimTypeFire;

  /// No description provided for @requestInfo.
  ///
  /// In en, this message translates to:
  /// **'Request Information'**
  String get requestInfo;

  /// No description provided for @assignedExpert.
  ///
  /// In en, this message translates to:
  /// **'Assigned Expert'**
  String get assignedExpert;

  /// No description provided for @approvedCompensationAmount.
  ///
  /// In en, this message translates to:
  /// **'Approved Compensation Amount'**
  String get approvedCompensationAmount;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @compensationAmountDzd.
  ///
  /// In en, this message translates to:
  /// **'{amount} DZD'**
  String compensationAmountDzd(String amount);

  /// No description provided for @subscriberInfoFromRegistration.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Info (from original registration)'**
  String get subscriberInfoFromRegistration;

  /// No description provided for @systemRegisteredData.
  ///
  /// In en, this message translates to:
  /// **'Data registered in the system'**
  String get systemRegisteredData;

  /// No description provided for @takafulPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'Takaful Plan Details'**
  String get takafulPlanDetails;

  /// No description provided for @unspecifiedPlan.
  ///
  /// In en, this message translates to:
  /// **'Unspecified plan'**
  String get unspecifiedPlan;

  /// No description provided for @coverageAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Coverage specifications and amount'**
  String get coverageAndAmount;

  /// No description provided for @premiumColon.
  ///
  /// In en, this message translates to:
  /// **'Premium:'**
  String get premiumColon;

  /// No description provided for @submissionDateColon.
  ///
  /// In en, this message translates to:
  /// **'Submission date:'**
  String get submissionDateColon;

  /// No description provided for @attachedDocumentsAndFiles.
  ///
  /// In en, this message translates to:
  /// **'Attached Documents & Files'**
  String get attachedDocumentsAndFiles;

  /// No description provided for @noDocsAttached.
  ///
  /// In en, this message translates to:
  /// **'No documents attached.'**
  String get noDocsAttached;

  /// No description provided for @docLabel.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get docLabel;

  /// No description provided for @previewFile.
  ///
  /// In en, this message translates to:
  /// **'Preview file'**
  String get previewFile;

  /// No description provided for @finalPolicyDocument.
  ///
  /// In en, this message translates to:
  /// **'Final Insurance Policy'**
  String get finalPolicyDocument;

  /// No description provided for @clickToUploadPolicy.
  ///
  /// In en, this message translates to:
  /// **'Click to upload insurance policy (PDF)'**
  String get clickToUploadPolicy;

  /// No description provided for @finalQuoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Final Quote (DZD):'**
  String get finalQuoteLabel;

  /// No description provided for @enterFinalQuoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the final quote amount'**
  String get enterFinalQuoteHint;

  /// No description provided for @reviewAndDecisionNotes.
  ///
  /// In en, this message translates to:
  /// **'Review & Decision Notes:'**
  String get reviewAndDecisionNotes;

  /// No description provided for @writeAcceptRejectNotes.
  ///
  /// In en, this message translates to:
  /// **'Write acceptance, rejection, or modification reason here...'**
  String get writeAcceptRejectNotes;

  /// No description provided for @rejectBtn.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectBtn;

  /// No description provided for @modificationBtn.
  ///
  /// In en, this message translates to:
  /// **'Request Modification'**
  String get modificationBtn;

  /// No description provided for @acceptBtn.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptBtn;

  /// No description provided for @issuePolicyBtn.
  ///
  /// In en, this message translates to:
  /// **'Issue Policy'**
  String get issuePolicyBtn;

  /// No description provided for @pleaseWriteNotesFirst.
  ///
  /// In en, this message translates to:
  /// **'Please write notes before rejecting or requesting modification'**
  String get pleaseWriteNotesFirst;

  /// No description provided for @pleaseEnterValidQuote.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quote amount before accepting'**
  String get pleaseEnterValidQuote;

  /// No description provided for @pleaseUploadFinalPolicy.
  ///
  /// In en, this message translates to:
  /// **'Please upload the final insurance policy'**
  String get pleaseUploadFinalPolicy;

  /// No description provided for @insurancePortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance Policy Requests'**
  String get insurancePortalTitle;

  /// No description provided for @insurancePortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and process incoming subscription requests'**
  String get insurancePortalSubtitle;

  /// No description provided for @searchByNameOrIdHint.
  ///
  /// In en, this message translates to:
  /// **'Search by client name or ID number...'**
  String get searchByNameOrIdHint;

  /// No description provided for @newInsuranceRequestsFilter.
  ///
  /// In en, this message translates to:
  /// **'New Insurance Requests'**
  String get newInsuranceRequestsFilter;

  /// No description provided for @dataLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String dataLoadingError(String error);

  /// No description provided for @requestTypeQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote Request'**
  String get requestTypeQuote;

  /// No description provided for @requestTypeInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance Request'**
  String get requestTypeInsurance;

  /// No description provided for @statusIssued.
  ///
  /// In en, this message translates to:
  /// **'Policy Issued'**
  String get statusIssued;

  /// No description provided for @accumulatedCommissions.
  ///
  /// In en, this message translates to:
  /// **'Accumulated commission balance'**
  String get accumulatedCommissions;

  /// No description provided for @requestWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Request Withdrawal'**
  String get requestWithdrawal;

  /// No description provided for @withdrawalAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Amount (DZD)'**
  String get withdrawalAmount;

  /// No description provided for @ccpAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'CCP Account Number'**
  String get ccpAccountNumber;

  /// No description provided for @withdrawalRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request sent successfully!'**
  String get withdrawalRequestSent;

  /// No description provided for @offerRefusedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer refused successfully'**
  String get offerRefusedSuccess;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance for this withdrawal'**
  String get insufficientBalance;

  /// No description provided for @operatorTakafulTitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful'**
  String get operatorTakafulTitle;

  /// No description provided for @operatorTakafulSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Takaful insurance solutions fully compliant with Sharia'**
  String get operatorTakafulSubtitle;

  /// No description provided for @operatorIttihadTitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria Al-Ittihad'**
  String get operatorIttihadTitle;

  /// No description provided for @operatorIttihadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modern protection packages at competitive prices'**
  String get operatorIttihadSubtitle;

  /// No description provided for @dahabiaCard.
  ///
  /// In en, this message translates to:
  /// **'Dahabia Card'**
  String get dahabiaCard;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @towingService.
  ///
  /// In en, this message translates to:
  /// **'Towing Service'**
  String get towingService;

  /// No description provided for @partnerDiscount.
  ///
  /// In en, this message translates to:
  /// **'Partner Discount'**
  String get partnerDiscount;

  /// No description provided for @discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% discount for Tameeni members'**
  String discountPercentage(String percent);

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open this file'**
  String get couldNotOpenFile;

  /// No description provided for @statusUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request status updated successfully'**
  String get statusUpdatedSuccess;

  /// No description provided for @zoomReceipt.
  ///
  /// In en, this message translates to:
  /// **'Zoom receipt'**
  String get zoomReceipt;

  /// No description provided for @adminActions.
  ///
  /// In en, this message translates to:
  /// **'Admin Actions'**
  String get adminActions;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note for the user (rejection reason or missing documents)...'**
  String get addNoteHint;

  /// No description provided for @rejectPermanently.
  ///
  /// In en, this message translates to:
  /// **'Permanently Reject'**
  String get rejectPermanently;

  /// No description provided for @requestsToday.
  ///
  /// In en, this message translates to:
  /// **'Requests today'**
  String get requestsToday;

  /// No description provided for @totalPoliciesCount.
  ///
  /// In en, this message translates to:
  /// **'Total policies: {count}'**
  String totalPoliciesCount(int count);

  /// No description provided for @appBrandName.
  ///
  /// In en, this message translates to:
  /// **'Tameeni Elite'**
  String get appBrandName;

  /// No description provided for @adminShareLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin: {amount} {currency}'**
  String adminShareLabel(String amount, String currency);

  /// No description provided for @operatorsShareLabel.
  ///
  /// In en, this message translates to:
  /// **'Operators: {amount} {currency}'**
  String operatorsShareLabel(String amount, String currency);

  /// No description provided for @newClientsCount.
  ///
  /// In en, this message translates to:
  /// **'New clients: {count} (100% admin)'**
  String newClientsCount(int count);

  /// No description provided for @returningClientsCount.
  ///
  /// In en, this message translates to:
  /// **'Returning: {count} (50/50)'**
  String returningClientsCount(int count);

  /// No description provided for @fromClientRate.
  ///
  /// In en, this message translates to:
  /// **'{rate}% from client'**
  String fromClientRate(String rate);

  /// No description provided for @newFullAdmin.
  ///
  /// In en, this message translates to:
  /// **'New: 100% admin | Old: 50/50'**
  String get newFullAdmin;

  /// No description provided for @requestsAndNin.
  ///
  /// In en, this message translates to:
  /// **'Requests & NIN (admin commission)'**
  String get requestsAndNin;

  /// No description provided for @returningClient.
  ///
  /// In en, this message translates to:
  /// **'Returning client (50/50)'**
  String get returningClient;

  /// No description provided for @newClient.
  ///
  /// In en, this message translates to:
  /// **'New client (100% admin)'**
  String get newClient;

  /// No description provided for @sinceLastMonth.
  ///
  /// In en, this message translates to:
  /// **'+12% since last month'**
  String get sinceLastMonth;

  /// No description provided for @atAiShare.
  ///
  /// In en, this message translates to:
  /// **'AT/AI: {amount} {currency}'**
  String atAiShare(String amount, String currency);

  /// No description provided for @auditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Operation log with date & time (seconds) • Payment gateway linked'**
  String get auditSubtitle;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @allPortals.
  ///
  /// In en, this message translates to:
  /// **'All portals'**
  String get allPortals;

  /// No description provided for @operatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator (AT/AI)'**
  String get operatorLabel;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @trackContractExpiry.
  ///
  /// In en, this message translates to:
  /// **'Track your contract expiry dates'**
  String get trackContractExpiry;

  /// No description provided for @activeAlertCount.
  ///
  /// In en, this message translates to:
  /// **'({count}) active alert'**
  String activeAlertCount(int count);

  /// No description provided for @allMyContracts.
  ///
  /// In en, this message translates to:
  /// **'All my contracts'**
  String get allMyContracts;

  /// No description provided for @generalNotifications.
  ///
  /// In en, this message translates to:
  /// **'General notifications'**
  String get generalNotifications;

  /// No description provided for @noAlertsCurrently.
  ///
  /// In en, this message translates to:
  /// **'No alerts at this time'**
  String get noAlertsCurrently;

  /// No description provided for @enablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications'**
  String get enablePushNotifications;

  /// No description provided for @autoAlertBefore15Days.
  ///
  /// In en, this message translates to:
  /// **'Auto alert 15 days before expiry'**
  String get autoAlertBefore15Days;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @urgentAlert.
  ///
  /// In en, this message translates to:
  /// **'Urgent alert'**
  String get urgentAlert;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysRemaining(int days);

  /// No description provided for @contractExpiresIn15Days.
  ///
  /// In en, this message translates to:
  /// **'Your insurance contract expires in 15 days'**
  String get contractExpiresIn15Days;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date: {date}'**
  String expiryDateLabel(String date);

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @algerTakaful.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful'**
  String get algerTakaful;

  /// No description provided for @maxImageSize5mb.
  ///
  /// In en, this message translates to:
  /// **'Maximum image size: 5MB'**
  String get maxImageSize5mb;

  /// No description provided for @imageSizeExceeds5mb.
  ///
  /// In en, this message translates to:
  /// **'Image size exceeds the maximum limit of 5MB'**
  String get imageSizeExceeds5mb;

  /// No description provided for @manualPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'Manual Payment Proof'**
  String get manualPaymentProof;

  /// No description provided for @uploadReceiptInstruction.
  ///
  /// In en, this message translates to:
  /// **'If you paid via bank transfer or CCP, please upload the receipt photo here.'**
  String get uploadReceiptInstruction;

  /// No description provided for @uploadReceiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt Photo'**
  String get uploadReceiptPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingPayment;

  /// No description provided for @deleteOfferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this offer?'**
  String get deleteOfferConfirm;

  /// No description provided for @offerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Offer deleted successfully'**
  String get offerDeleted;

  /// No description provided for @bestValueSet.
  ///
  /// In en, this message translates to:
  /// **'Offer marked as best value'**
  String get bestValueSet;

  /// No description provided for @bestValueUnset.
  ///
  /// In en, this message translates to:
  /// **'Best value removed'**
  String get bestValueUnset;

  /// No description provided for @offerName.
  ///
  /// In en, this message translates to:
  /// **'Promotional offer name'**
  String get offerName;

  /// No description provided for @premiumAmount.
  ///
  /// In en, this message translates to:
  /// **'Premium amount (DZD)'**
  String get premiumAmount;

  /// No description provided for @suggestedTabarruRate.
  ///
  /// In en, this message translates to:
  /// **'Suggested donation rate for subscriber'**
  String get suggestedTabarruRate;

  /// No description provided for @coverageLimit.
  ///
  /// In en, this message translates to:
  /// **'Coverage limit for claims'**
  String get coverageLimit;

  /// No description provided for @donationFundRate.
  ///
  /// In en, this message translates to:
  /// **'Donation fund rate (%)'**
  String get donationFundRate;

  /// No description provided for @surplusDistributionRate.
  ///
  /// In en, this message translates to:
  /// **'Surplus distribution rate (%)'**
  String get surplusDistributionRate;

  /// No description provided for @claimsDurationDays.
  ///
  /// In en, this message translates to:
  /// **'Claims settlement duration (days)'**
  String get claimsDurationDays;

  /// No description provided for @offerIcon.
  ///
  /// In en, this message translates to:
  /// **'Promotional offer icon'**
  String get offerIcon;

  /// No description provided for @certifiedVerified.
  ///
  /// In en, this message translates to:
  /// **'Certified & Verified'**
  String get certifiedVerified;

  /// No description provided for @rafiqAssistant.
  ///
  /// In en, this message translates to:
  /// **'Rafiq Assistant'**
  String get rafiqAssistant;

  /// No description provided for @recommendedBestValue.
  ///
  /// In en, this message translates to:
  /// **'Recommended offer (best value for subscriber)'**
  String get recommendedBestValue;

  /// No description provided for @offerSaved.
  ///
  /// In en, this message translates to:
  /// **'Offer saved successfully'**
  String get offerSaved;

  /// No description provided for @claimsDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Claims settlement'**
  String get claimsDurationLabel;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @errorOpeningFile.
  ///
  /// In en, this message translates to:
  /// **'Error opening file: {error}'**
  String errorOpeningFile(String error);

  /// No description provided for @aiPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Algerie Ittihadd'**
  String get aiPortalTitle;

  /// No description provided for @aiOffersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage promotional offers'**
  String get aiOffersSubtitle;

  /// No description provided for @atPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Algeria Takaful'**
  String get atPortalTitle;

  /// No description provided for @systemOperator.
  ///
  /// In en, this message translates to:
  /// **'System Operator'**
  String get systemOperator;

  /// No description provided for @checkEmailConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm your account.'**
  String get checkEmailConfirm;

  /// No description provided for @takafulPlan.
  ///
  /// In en, this message translates to:
  /// **'Takaful Plan'**
  String get takafulPlan;

  /// No description provided for @financeMinistry2021.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Finance Decision 2021'**
  String get financeMinistry2021;

  /// No description provided for @financeMinistry2021Desc.
  ///
  /// In en, this message translates to:
  /// **'Regulates contracts and surplus distribution'**
  String get financeMinistry2021Desc;

  /// No description provided for @nationalShariahBody.
  ///
  /// In en, this message translates to:
  /// **'National Shariah Body'**
  String get nationalShariahBody;

  /// No description provided for @nationalShariahBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Shariah oversight on every contract'**
  String get nationalShariahBodyDesc;

  /// No description provided for @chipShariahOversight.
  ///
  /// In en, this message translates to:
  /// **'Shariah Oversight'**
  String get chipShariahOversight;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr', 'kab'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'kab': return AppLocalizationsKab();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
