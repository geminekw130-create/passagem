import 'package:cliente/core/services/data_store.dart';

import 'package:cliente/core/extensions/workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cliente/core/utils/translate.dart';
import 'package:cliente/presentation/screens/payment/payment_geteway_screen.dart';

import '../../../core/utils/common_widget.dart';
import '../../../core/utils/theme/project_color.dart';
import '../../../core/utils/theme/theme_style.dart';
import '../../cubits/book_ride_cubit.dart';
import '../../cubits/general_cubit.dart';
import '../../cubits/location/get_nearby_drivers_cubit.dart';
import '../../cubits/payment/payment_cubit.dart';
import '../../cubits/realtime/get_ride_request_status_cubit.dart';
import '../../cubits/realtime/ride_request_cubit.dart';
import '../../cubits/realtime/update_ride_request_parameter.dart';
import '../../widgets/review_widget.dart';
import '../Home/item_home_screen.dart';

class RiderPaymentScreen extends StatefulWidget {
  final String? bookingId, rideId, fare, paymentUrl;
  const RiderPaymentScreen(
      {super.key, this.bookingId, this.rideId, this.fare, this.paymentUrl});

  @override
  State<RiderPaymentScreen> createState() => _RiderPaymentScreenState();
}

class _RiderPaymentScreenState extends State<RiderPaymentScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.rideId!.isNotEmpty) {
      context.read<GetRideRequestPaymentCubit>().resetStatus();
      context
          .read<GetRideRequestPaymentCubit>()
          .listenToPaymentStatusAndMethod(rideId: widget.rideId!);
    }
  }

  String paymentStatus = "";
  bool isCash = true;
  bool isOpenReview = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: CustomAppBarNew(
          title: "Trip Summary".translate(context),
          onBackTap: () {
            if (paymentStatus == "Collected") {
              box.delete("ride_data");
              context.read<GetPolylineCubit>().resetPolylines();
              context.read<BookRideRealTimeDataBaseCubit>().resetState();
              goTo(const ItemHomeScreen());

            } else {
              dialogExit(context);
            }
          },
        ),
        body: BlocListener<GetRideRequestPaymentCubit, Map<String, String>>(
          listener: (context, state) {
            if (state["paymentMethod"] == "cash") {
              context.read<PaymentCubit>().selectMethod(PaymentMethod.cash);
            } else {
              context.read<PaymentCubit>().selectMethod(PaymentMethod.online);
            }

            if (state["paymentStatus"] == "collected") {
              paymentStatus = "collected";
              box.delete("ride_data");
              context.read<GetPolylineCubit>().resetPolylines();
              context.read<BookRideRealTimeDataBaseCubit>().resetState();
              if (isOpenReview) return;
              isOpenReview = true;
              showModalBottomSheet(
                context: context,
                enableDrag: false, // disables drag-to-close
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CustomReviewWidget(
                  bookingId: widget.bookingId,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<PaymentCubit, PaymentMethod?>(
              builder: (context, selectedMethod) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      BlocBuilder<RideRequestCubit, RideRequestState>(
                          builder: (context, state) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: ClipOval(
                                child:
                                    myNetworkImage(state.acceptedDriverImageUrl),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: notifires.getbgcolor,
                                  border: Border.all(color: greentext)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: greentext,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "RIDE COMPLETE".translate(context),
                                    style: regular(context)
                                        .copyWith(color: greentext),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: notifires.getbgcolor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLocationRow(
                                    icon: Icons.circle,
                                    color: Colors.green,
                                    bgColor: Colors.green.shade100,
                                    text: state.pickupAddress,
                                    context: context,
                                  ),
                                  const SizedBox(height: 10),
                                  buildLocationRow(
                                    icon: Icons.location_on_outlined,
                                    color: Colors.red,
                                    bgColor: Colors.red.shade100,
                                    text: state.dropOffAddress,
                                    context: context,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: grey5,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${"Select a payment method to pay".translate(context)} \n${state.acceptedDriverName}",
                              style:
                                  heading3Grey1(context).copyWith(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            BlocBuilder<GeneralCubit, GeneralState>(
                                builder: (context, state) {
                              return Text(
                                "$currency ${widget.fare}",
                                style: heading1(context),
                              );
                            }),
                          ],
                        );
                      }),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: notifires.getboxcolor,
                            boxShadow: [
                              BoxShadow(
                                  color: grey5, blurRadius: 5, spreadRadius: 3)
                            ],
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        "assets/images/cashIcon.png",
                                        height: 30,
                                        width: 30,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Cash".translate(context),
                                        style: headingBlack(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio(
                                  activeColor: greentext,
                                  value: PaymentMethod.cash,
                                  groupValue: selectedMethod,
                                  onChanged: (value) {
                                    if (value != null) {
                                      context
                                          .read<PaymentCubit>()
                                          .selectMethod(value);
                                      context
                                          .read<UpdateRideRequestParameterCubit>()
                                          .updatePaymentMehod(
                                              rideId: widget.rideId ?? "",
                                              paymentMethod: "cash");
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        "assets/images/onlineIcon.png",
                                        height: 30,
                                        width: 30,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Online".translate(context),
                                        style: headingBlack(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio(
                                  activeColor: greentext,
                                  value: PaymentMethod.online,
                                  groupValue: selectedMethod,
                                  onChanged: (value) {
                                    if (value != null) {
                                      context
                                          .read<PaymentCubit>()
                                          .selectMethod(value);
                                      context
                                          .read<UpdateRideRequestParameterCubit>()
                                          .updatePaymentMehod(
                                              rideId: widget.rideId ?? "",
                                              paymentMethod: "online");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                      selectedMethod == PaymentMethod.cash
                          ? const SizedBox()
                          : BlocConsumer<UpdatePaymentByUserCubit,
                              UpdatePaymentByUserState>(
                              builder: (context, state) {
                                return CustomsButtons(
                                  textColor: blackColor,
                                  backgroundColor: themeColor,
                                  onPressed: () {
                                    goTo(PaymentsScreen(
                                      rideId: widget.rideId,
                                      url: widget.paymentUrl,
                                    ));
                                  },
                                  text: "Pay Now",
                                );
                              },
                              listener: (context, state) {
                                if (state is UpdatePaymentLoading) {
                                  Widgets.showLoader(context);
                                }
                                if (state is UpdatePaymentSuceess) {
                                  Widgets.hideLoder(context);
                                  showModalBottomSheet(
                                    context: context,
                                    enableDrag: false, // disables drag-to-close
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CustomReviewWidget(
                                      bookingId: widget.bookingId,
                                    ),
                                  );
                                } else if (state is UpdatePaymentFailure) {
                                  Widgets.hideLoder(context);
                                  showErrorToastMessage(
                                      state.paymentMessage ?? "");
                                }
                              },
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
