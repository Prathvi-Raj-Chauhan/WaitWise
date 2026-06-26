import 'package:go_router/go_router.dart';
import 'package:wait_wise/screens/login.dart';
import 'package:wait_wise/screens/register.dart';
import 'package:wait_wise/screens/role_select_page.dart';
import 'package:wait_wise/screens/reception_screen.dart';
import 'package:wait_wise/screens/doctor_screen.dart';
import 'package:wait_wise/screens/wait_room.dart';
import 'package:wait_wise/screens/patient_history_page.dart';

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
      builder: (context, state) => const RoleSelectPage(),
    ),
    GoRoute(
      path: '/reception/:clinicId',
      builder: (context, state) {
        final clinicId = state.pathParameters['clinicId']!;
        return ReceptionPage(clinicId: clinicId);
      },
    ),
    GoRoute(
      path: '/doctor',
      builder: (context, state) => const DoctorScreen(),
    ),
    GoRoute(
      path: '/wait-room',
      builder: (context, state) => const WaitRoom(),
    ),
    GoRoute(
      path: '/patient-history',
      builder: (context, state) => const PatientHistoryPage(),
    ),
  ],
);
