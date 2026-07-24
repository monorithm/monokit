import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

import '../blocks/blocks_page.dart';
import '../blocks/for_you_block.dart';
import '../blocks/interest_block.dart';
import '../blocks/post_block.dart';
import '../blocks/post_detail_block.dart';
import '../blocks/search_block.dart';
import '../blocks/signin_block.dart';
import '../container/gallery_shell.dart';
import '../sections/actions_page.dart';
import '../sections/chat_page.dart';
import '../sections/commerce_page.dart';
import '../sections/feedback_page.dart';
import '../sections/forms_page.dart';
import '../sections/foundations_page.dart';
import '../sections/media_page.dart';
import '../sections/navigation_page.dart';
import '../sections/overlays_page.dart';
import '../sections/overview_page.dart';

GoRoute _page(String path, Widget page) =>
    GoRoute(path: path, builder: (context, state) => page);

GoRoute _block(String path, String title, Widget block) => GoRoute(
  path: path,
  builder: (context, state) => BlockViewer(title: title, child: block),
);

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => GalleryShell(child: child),
      routes: <RouteBase>[
        _page('/', const OverviewPage()),
        _page('/foundations', const FoundationsPage()),
        _page('/actions', const ActionsPage()),
        _page('/forms', const FormsPage()),
        _page('/overlays', const OverlaysPage()),
        _page('/navigation', const NavigationPage()),
        _page('/feedback', const FeedbackPage()),
        _page('/chat', const ChatPage()),
        _page('/media', const MediaPage()),
        _page('/commerce', const CommercePage()),
        _page('/blocks', const BlocksIndexPage()),
        _block('/blocks/signin', 'Sign in', const SignInBlock()),
        _block('/blocks/for-you', 'For You', const ForYouBlock()),
        _block('/blocks/search', 'Search', const SearchBlock()),
        _block('/blocks/post', 'Post composer', const PostBlock()),
        _block('/blocks/post-detail', 'Post detail', const PostDetailBlock()),
        _block('/blocks/interest', 'Interest thread', const InterestBlock()),
      ],
    ),
  ],
);
