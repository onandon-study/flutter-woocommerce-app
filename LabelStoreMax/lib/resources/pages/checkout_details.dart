//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/billing_details.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/customer_address.dart';
import 'package:flutter_app/app/models/customer_country.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/customer_address_input.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/switch_address_tab.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:validated/validated.dart' as validate;

class CheckoutDetailsPage extends StatefulWidget {
  CheckoutDetailsPage();

  @override
  _CheckoutDetailsPageState createState() => _CheckoutDetailsPageState();
}

class _CheckoutDetailsPageState extends State<CheckoutDetailsPage> {
  _CheckoutDetailsPageState();

  bool _hasDifferentShippingAddress = false, valRememberDetails = true;
  int activeTabIndex = 0;

  // TEXT CONTROLLERS
  final TextEditingController
      // billing
      _txtBillingFirstName = TextEditingController(),
      _txtBillingLastName = TextEditingController(),
      _txtBillingAddressLine = TextEditingController(),
      _txtBillingCity = TextEditingController(),
      _txtBillingPostalCode = TextEditingController(),
      _txtBillingEmailAddress = TextEditingController(),
      // shipping
      _txtShippingFirstName = TextEditingController(),
      _txtShippingLastName = TextEditingController(),
      _txtShippingAddressLine = TextEditingController(),
      _txtShippingCity = TextEditingController(),
      _txtShippingPostalCode = TextEditingController(),
      _txtShippingEmailAddress = TextEditingController();

  CustomerCountry _billingCountry, _shippingCountry;

  Widget activeTab;

  Widget tabShippingDetails() => CustomerAddressInput(
        txtControllerFirstName: _txtShippingFirstName,
        txtControllerLastName: _txtShippingLastName,
        txtControllerAddressLine: _txtShippingAddressLine,
        txtControllerCity: _txtShippingCity,
        txtControllerPostalCode: _txtShippingPostalCode,
        txtControllerEmailAddress: _txtShippingEmailAddress,
        customerCountry: _shippingCountry,
        onTapCountry: () => _navigateToSelectCountry(type: "shipping"),
      );

  Widget tabBillingDetails() => CustomerAddressInput(
        txtControllerFirstName: _txtBillingFirstName,
        txtControllerLastName: _txtBillingLastName,
        txtControllerAddressLine: _txtBillingAddressLine,
        txtControllerCity: _txtBillingCity,
        txtControllerPostalCode: _txtBillingPostalCode,
        txtControllerEmailAddress: _txtBillingEmailAddress,
        customerCountry: _billingCountry,
        onTapCountry: () => _navigateToSelectCountry(type: "billing"),
      );

  @override
  void initState() {
    super.initState();

    if (CheckoutSession.getInstance.billingDetails.billingAddress == null) {
      CheckoutSession.getInstance.billingDetails.initSession();
      CheckoutSession.getInstance.billingDetails.shippingAddress.initAddress();
      CheckoutSession.getInstance.billingDetails.billingAddress.initAddress();
    }
    BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;
    _setFieldsFromCustomerAddress(billingDetails.billingAddress,
        type: "billing");
    _setFieldsFromCustomerAddress(billingDetails.shippingAddress,
        type: "shipping");

    _hasDifferentShippingAddress =
        CheckoutSession.getInstance.shipToDifferentAddress;
    valRememberDetails = billingDetails.rememberDetails ?? true;
    _setCustomersDetails();
  }

  _setCustomersDetails() async {
    CustomerAddress sfCustomerBillingAddress =
        await CheckoutSession.getInstance.getBillingAddress();
    _setFieldsFromCustomerAddress(sfCustomerBillingAddress, type: "billing");

    CustomerAddress sfCustomerShippingAddress =
        await CheckoutSession.getInstance.getShippingAddress();
    _setFieldsFromCustomerAddress(sfCustomerShippingAddress, type: "shipping");
  }

  _setFieldsFromCustomerAddress(CustomerAddress customerAddress,
      {@required String type}) {
    assert(type != "");
    if (customerAddress == null) {
      return;
    }
    _setFields(
      firstName: customerAddress.firstName,
      lastName: customerAddress.lastName,
      addressLine: customerAddress.addressLine,
      city: customerAddress.city,
      postalCode: customerAddress.postalCode,
      emailAddress: customerAddress.emailAddress,
      customerCountry: customerAddress.customerCountry,
      type: type,
    );
  }

  _setFields(
      {@required String firstName,
      @required String lastName,
      @required String addressLine,
      @required String city,
      @required String postalCode,
      @required String emailAddress,
      @required CustomerCountry customerCountry,
      String type}) {
    if (type == "billing") {
      _txtBillingFirstName.text = firstName;
      _txtBillingLastName.text = lastName;
      _txtBillingAddressLine.text = addressLine;
      _txtBillingCity.text = city;
      _txtBillingPostalCode.text = postalCode;
      _txtBillingEmailAddress.text = emailAddress;
      _billingCountry = customerCountry;
    } else if (type == "shipping") {
      _txtShippingFirstName.text = firstName;
      _txtShippingLastName.text = lastName;
      _txtShippingAddressLine.text = addressLine;
      _txtShippingCity.text = city;
      _txtShippingPostalCode.text = postalCode;
      _txtShippingEmailAddress.text = emailAddress;
      _shippingCountry = customerCountry;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          trans("Billing & Shipping Details"),
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          (_hasDifferentShippingAddress
                              ? Padding(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      SwitchAddressTab(
                                          title: trans("Billing Details"),
                                          currentTabIndex: activeTabIndex,
                                          type: "billing",
                                          onTapAction: () => setState(() {
                                                activeTabIndex = 0;
                                                activeTab = tabBillingDetails();
                                              })),
                                      SwitchAddressTab(
                                          title: trans("Shipping Address"),
                                          currentTabIndex: activeTabIndex,
                                          type: "shipping",
                                          onTapAction: () => setState(() {
                                                activeTabIndex = 1;
                                                activeTab =
                                                    tabShippingDetails();
                                              })),
                                    ].where((e) => e != null).toList(),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                )
                              : null),
                        ].where((e) => e != null).toList(),
                      ),
                      height: 60,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ThemeColor.get(context).backgroundContainer,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow:
                              (Theme.of(context).brightness == Brightness.light)
                                  ? wsBoxShadow()
                                  : null,
                        ),
                        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                        child: (activeTab ?? tabBillingDetails()),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 160,
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          trans("Ship to a different address?"),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Checkbox(
                          value: _hasDifferentShippingAddress,
                          onChanged: _onChangeShipping,
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          trans("Remember my details"),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Checkbox(
                          value: valRememberDetails,
                          onChanged: (bool value) {
                            setState(() {
                              valRememberDetails = value;
                            });
                          },
                        )
                      ],
                    ),
                    PrimaryButton(
                      title: trans("USE DETAILS"),
                      action: () => _useDetailsTapped(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _useDetailsTapped() {
    CustomerAddress customerBillingAddress = _setCustomerAddress(
        firstName: _txtBillingFirstName.text,
        lastName: _txtBillingLastName.text,
        addressLine: _txtBillingAddressLine.text,
        city: _txtBillingCity.text,
        postalCode: _txtBillingPostalCode.text,
        emailAddress: _txtBillingEmailAddress.text,
        customerCountry: _billingCountry);

    CheckoutSession.getInstance.billingDetails.shippingAddress =
        customerBillingAddress;
    CheckoutSession.getInstance.billingDetails.billingAddress =
        customerBillingAddress;

    if (_hasDifferentShippingAddress == true) {
      CustomerAddress customerShippingAddress = _setCustomerAddress(
          firstName: _txtShippingFirstName.text,
          lastName: _txtShippingLastName.text,
          addressLine: _txtShippingAddressLine.text,
          city: _txtShippingCity.text,
          postalCode: _txtShippingPostalCode.text,
          emailAddress: _txtShippingEmailAddress.text,
          customerCountry: _shippingCountry);

      if (customerShippingAddress.hasMissingFields()) {
        showToastNotification(
          context,
          title: trans("Oops"),
          description: trans(
              "Invalid shipping address, please check your shipping details"),
          style: ToastNotificationStyleType.WARNING,
        );
        return;
      }

      // Email validation
      String billingEmail = _txtBillingEmailAddress.text;
      String shippingEmail = _txtShippingEmailAddress.text;
      if (billingEmail.isNotEmpty && !validate.isEmail(billingEmail)) {
        showToastNotification(
          context,
          title: trans("Oops"),
          description: trans("Please enter a valid billing email"),
          style: ToastNotificationStyleType.WARNING,
        );
        return;
      }

      if (shippingEmail.isNotEmpty && !validate.isEmail(shippingEmail)) {
        showToastNotification(
          context,
          title: trans("Oops"),
          description: trans("Please enter a valid shipping email"),
          style: ToastNotificationStyleType.WARNING,
        );
        return;
      }

      CheckoutSession.getInstance.billingDetails.shippingAddress =
          customerShippingAddress;
    }

    if (valRememberDetails == true) {
      CheckoutSession.getInstance.saveBillingAddress();
      CheckoutSession.getInstance.saveShippingAddress();
    } else {
      CheckoutSession.getInstance.clearBillingAddress();
      CheckoutSession.getInstance.clearShippingAddress();
    }

    CheckoutSession.getInstance.billingDetails.rememberDetails =
        valRememberDetails;
    CheckoutSession.getInstance.shipToDifferentAddress =
        _hasDifferentShippingAddress;

    CheckoutSession.getInstance.shippingType = null;
    Navigator.pop(context);
  }

  _onChangeShipping(bool value) async {
    _hasDifferentShippingAddress = value;
    activeTabIndex = 1;
    activeTab = value == true ? tabShippingDetails() : tabBillingDetails();

    CustomerAddress sfCustomerShippingAddress =
        await CheckoutSession.getInstance.getShippingAddress();
    if (sfCustomerShippingAddress == null) {
      _setFields(
          firstName: "",
          lastName: "",
          addressLine: "",
          city: "",
          postalCode: "",
          emailAddress: "",
          customerCountry: CustomerCountry());
    }
    setState(() {});
  }

  CustomerAddress _setCustomerAddress(
      {@required String firstName,
      @required String lastName,
      @required String addressLine,
      @required String city,
      @required String postalCode,
      @required String emailAddress,
      @required CustomerCountry customerCountry}) {
    CustomerAddress customerShippingAddress = CustomerAddress();
    customerShippingAddress.firstName = firstName;
    customerShippingAddress.lastName = lastName;
    customerShippingAddress.addressLine = addressLine;
    customerShippingAddress.city = city;
    customerShippingAddress.postalCode = postalCode;
    customerShippingAddress.customerCountry = customerCountry;
    customerShippingAddress.emailAddress = emailAddress;
    return customerShippingAddress;
  }

  _navigateToSelectCountry({@required String type}) {
    Navigator.pushNamed(context, "/customer-countries").then((value) {
      if (value == null) {
        return;
      }
      if (type == "billing") {
        _billingCountry =
            CustomerCountry.fromDefaultShipping(defaultShipping: value);
        activeTab = tabBillingDetails();
      } else if (type == "shipping") {
        _shippingCountry =
            CustomerCountry.fromDefaultShipping(defaultShipping: value);
        activeTab = tabShippingDetails();
      }
      setState(() {});
    });
  }
}
