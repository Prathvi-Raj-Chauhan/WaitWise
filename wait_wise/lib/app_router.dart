import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wait_wise/screens/login.dart';
import 'package:wait_wise/screens/register.dart';
import 'package:wait_wise/screens/role_select_page.dart';
import 'package:wait_wise/screens/reception_screen.dart';
import 'package:wait_wise/screens/doctor_screen.dart';
import 'package:wait_wise/screens/wait_room.dart';
import 'package:wait_wise/screens/patient_history_page.dart';
import 'package:wait_wise/services/dioClient.dart';


Future<String?> checkAuth(BuildContext context, GoRouterState state) async {
    final client = Dioclient.dio;
    if (state.uri.path == '/login') return null;

    try {
      final res = await client.get('/auth-check');
      if (res.statusCode == 401) {
        return '/login';
      }
      return null;
    } catch (_) {
      return '/login';
    }
  }
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/role-select',
      redirect: (context, state) => checkAuth(context, state),
      builder: (context, state) => const RoleSelectPage(),
    ),
    GoRoute(
      path: '/reception/:clinicId',
      redirect: (context, state) => checkAuth(context, state),

      builder: (context, state) {
        final clinicId = state.pathParameters['clinicId']!;
        return ReceptionPage(clinicId: clinicId);
      },
    ),
    GoRoute(
      path: '/doctor',
      redirect: (context, state) => checkAuth(context, state),

      builder: (context, state) => const DoctorScreen(),
    ),
    GoRoute(
      path: '/wait-room',
      redirect: (context, state) => checkAuth(context, state),
      builder: (context, state) => const WaitRoom(),
    ),
    GoRoute(
      path: '/patient-history',
      redirect: (context, state) => checkAuth(context, state),
      builder: (context, state) => const PatientHistoryPage(),
    ),
  ],
);
