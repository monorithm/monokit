import 'package:monokit/monokit.dart';

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
    path: '/honest',
    title: 'Honest states',
    navLabel: 'Honest states',
    description: 'The command lifecycle as design vocabulary',
    icon: MonoIcons.clock,
    group: 'Differentiators',
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
    path: '/blocks',
    title: 'Blocks',
    navLabel: 'Blocks',
    description: 'Production-style example screens built from the kit',
    icon: MonoIcons.image,
    group: 'Blocks',
  ),
];
