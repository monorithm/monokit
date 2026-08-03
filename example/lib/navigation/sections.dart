import 'package:monokit_ui/monokit_ui.dart';

/// Sidebar metadata for a gallery destination. `★`-grouped sections are
/// Monorithm's differentiator families.
class GallerySection {
  const GallerySection({
    required this.path,
    required this.title,
    required this.navLabel,
    required this.description,
    required this.icon,
    required this.group,
  });

  final String path;
  final String title;
  final String navLabel;
  final String description;
  final MonoIconData icon;
  final String group;
}

const List<GallerySection> gallerySections = <GallerySection>[
  GallerySection(
    path: '/',
    title: 'Overview',
    navLabel: 'Overview',
    description: 'A production-grade, self-documenting Monokit showcase',
    icon: MonoIcons.sparkles,
    group: 'Get started',
  ),
  GallerySection(
    path: '/foundations',
    title: 'Foundations',
    navLabel: 'Foundations',
    description: 'The design language: color, type, elevation, motion, icons',
    icon: MonoIcons.image,
    group: 'Get started',
  ),
  GallerySection(
    path: '/decisions',
    title: 'Decisions',
    navLabel: 'Decisions',
    description: 'The four axes: motion, density, surface, theme',
    icon: MonoIcons.sparkles,
    group: 'Get started',
  ),
  GallerySection(
    path: '/responsive',
    title: 'Responsive',
    navLabel: 'Responsive',
    description: 'The breakpoint ladder — drag, compare, and pin any viewport',
    icon: MonoIcons.grid,
    group: 'Get started',
  ),
  GallerySection(
    path: '/actions',
    title: 'Actions',
    navLabel: 'Actions',
    description: 'Buttons and badges — every variant, size, and state',
    icon: MonoIcons.star,
    group: 'Components',
  ),
  GallerySection(
    path: '/forms',
    title: 'Forms',
    navLabel: 'Forms',
    description: 'Inputs, fields, selection, and OTP',
    icon: MonoIcons.check,
    group: 'Components',
  ),
  GallerySection(
    path: '/overlays',
    title: 'Overlays',
    navLabel: 'Overlays',
    description: 'Dialogs, sheets, popovers, tooltips, menus',
    icon: MonoIcons.more,
    group: 'Components',
  ),
  GallerySection(
    path: '/navigation',
    title: 'Navigation',
    navLabel: 'Navigation',
    description: 'Bottom nav, tabs, accordion, breadcrumb, pagination, cards',
    icon: MonoIcons.menu,
    group: 'Components',
  ),
  GallerySection(
    path: '/feedback',
    title: 'Feedback',
    navLabel: 'Feedback',
    description: 'Alerts, banners, progress, skeletons, empty states',
    icon: MonoIcons.receipt,
    group: 'Components',
  ),
  GallerySection(
    path: '/data-display',
    title: 'Data display',
    navLabel: 'Data display',
    description: 'Avatars, cards, separators, and the loading family',
    icon: MonoIcons.user,
    group: 'Components',
  ),
  GallerySection(
    path: '/chat',
    title: 'Chat',
    navLabel: 'Chat',
    description: 'Messages, bubbles, receipts, attachments, composer',
    icon: MonoIcons.message,
    group: 'Differentiators',
  ),
  GallerySection(
    path: '/media',
    title: 'Media',
    navLabel: 'Media',
    description: 'Immersive surfaces, feed, live, voice, calls',
    icon: MonoIcons.video,
    group: 'Differentiators',
  ),
  GallerySection(
    path: '/commerce',
    title: 'Commerce',
    navLabel: 'Commerce',
    description: 'Prices, product cards, order status',
    icon: MonoIcons.bag,
    group: 'Differentiators',
  ),
  GallerySection(
    path: '/scenarios',
    title: 'Scenarios',
    navLabel: 'Scenarios',
    description: 'Full-fidelity product screens — frame them on any device',
    icon: MonoIcons.play,
    group: 'Scenarios',
  ),
];
