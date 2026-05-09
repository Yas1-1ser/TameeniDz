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
  /// **'Pending Review'**
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
  /// **'Submit a Request'**
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
  /// **'Platform Commission (4%)'**
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
  /// **'Algeria Takaful'**
  String get algeriaTakaful;

  /// No description provided for @alIttihad.
  ///
  /// In en, this message translates to:
  /// **'Al-Ittihad'**
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
  /// **'Amount (DZD)'**
  String get amountDzd;

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
  /// **'Digital Takaful • Sharia Compliant • Secure'**
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
  /// **'Best Value'**
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
  /// **'No plans available at the moment'**
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
  /// **'As an elite financial mediator, Tameeni Elite operates within a strictly defined perimeter designed to ensure absolute impartiality and ethical transparency. We do not hold client funds; rather, we orchestrate the secure alignment of Takaful principles between participants and operators.\\n\\nOur role is fundamentally advisory and protective, ensuring that every contractual engagement meets rigorous institutional standards before execution. This separation of powers is central to our commitment to Sovereign Trust.'**
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
  /// **'Account created successfully'**
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

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user? This action cannot be undone.'**
  String get deleteUserConfirmation;

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
