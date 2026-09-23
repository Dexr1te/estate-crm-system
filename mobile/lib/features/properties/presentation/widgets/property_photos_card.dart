import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PropertyPhotosCard extends StatefulWidget {
  final int propertyId;
  final List<PropertyPhoto> photos;
  final VoidCallback onChanged;

  const PropertyPhotosCard({
    super.key,
    required this.propertyId,
    required this.photos,
    required this.onChanged,
  });

  @override
  State<PropertyPhotosCard> createState() => _PropertyPhotosCardState();
}

class _PropertyPhotosCardState extends State<PropertyPhotosCard> {
  bool _busy = false;

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final picked = await Injector.fileGateway.pickImages();
    if (picked.isEmpty || !mounted) return;

    setState(() => _busy = true);
    for (final image in picked) {
      if (image.size > maxPhotoBytes) {
        if (mounted) {
          showActionUnavailable(
              context, l10n.propertiesPhotoTooLarge(image.name));
        }
        continue;
      }
      try {
        await Injector.propertiesRepository
            .addPhoto(widget.propertyId, image.path, image.name);
      } catch (err) {
        if (!mounted) return;
        showActionUnavailable(context, l10n.propertiesPhotoFailed(image.name));
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onChanged();
  }

  Future<void> _remove(PropertyPhoto photo) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.propertiesPhotoDelete,
      content: l10n.propertiesPhotoDeleteConfirm,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      await Injector.propertiesRepository
          .deletePhoto(widget.propertyId, photo.id);
      _PhotoBytes.forget(photo.id);
    } catch (err) {
      if (mounted) {
        showActionUnavailable(
            context, apiFailureLabel(l10n, ApiFailure.from(err)));
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onChanged();
  }

  Future<void> _move(int from, int to) async {
    final ids = widget.photos.map((p) => p.id).toList();
    final moved = ids.removeAt(from);
    ids.insert(from < to ? to - 1 : to, moved);

    setState(() => _busy = true);
    try {
      await Injector.propertiesRepository.reorderPhotos(widget.propertyId, ids);
      PropertyCovers.forget(widget.propertyId);
    } catch (err) {
      if (mounted) {
        showActionUnavailable(
            context,
            apiFailureLabel(
                AppLocalizations.of(context), ApiFailure.from(err)));
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onChanged();
  }

  Future<void> _open(int index) async {
    final removed =
        await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(
      builder: (_) => _PhotoViewer(
        propertyId: widget.propertyId,
        photos: widget.photos,
        initialIndex: index,
        onRemove: _remove,
      ),
    ));
    if (removed == true && mounted) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.propertiesPhotos)),
              Text(
                widget.photos.isEmpty
                    ? ''
                    : l10n.propertiesPhotoCount(widget.photos.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: t.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.photos.isEmpty)
            Text(
              l10n.propertiesNoPhotos,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.35,
                  color: t.textSecondary),
            )
          else ...[
            SizedBox(
              height: 104,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: true,
                padding: EdgeInsets.zero,
                itemCount: widget.photos.length,
                onReorder: _move,
                proxyDecorator: (child, _, __) => child,
                itemBuilder: (_, i) => Padding(
                  key: ValueKey(widget.photos[i].id),
                  padding: EdgeInsets.only(
                      right: i == widget.photos.length - 1 ? 0 : 8),
                  child: _Thumbnail(
                    propertyId: widget.propertyId,
                    photo: widget.photos[i],
                    onTap: () => _open(i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              l10n.propertiesPhotosHint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11,
                  height: 1.35,
                  color: t.textHint),
            ),
          ],
          const SizedBox(height: 12),
          AppGhostButton(
            label: l10n.propertiesAddPhotos,
            onPressed: _busy ? null : _add,
          ),
        ],
      ),
    );
  }
}

class _PhotoBytes {
  static final Map<int, Uint8List> _cache = {};

  static Future<Uint8List> of(int propertyId, int photoId) async {
    final held = _cache[photoId];
    if (held != null) return held;
    final bytes =
        await Injector.propertiesRepository.getPhotoBytes(propertyId, photoId);
    final data = Uint8List.fromList(bytes);
    _cache[photoId] = data;
    return data;
  }

  static void forget(int photoId) => _cache.remove(photoId);
}

class _Thumbnail extends StatelessWidget {
  final int propertyId;
  final PropertyPhoto photo;
  final VoidCallback onTap;

  const _Thumbnail({
    required this.propertyId,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        child: SizedBox(
          width: 132,
          height: 104,
          child: _PhotoImage(
            propertyId: propertyId,
            photo: photo,
            fit: BoxFit.cover,
            placeholderColor: t.surfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PhotoImage extends StatelessWidget {
  final int propertyId;
  final PropertyPhoto photo;
  final BoxFit fit;
  final Color placeholderColor;

  const _PhotoImage({
    required this.propertyId,
    required this.photo,
    required this.fit,
    required this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
        future: _PhotoBytes.of(propertyId, photo.id),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Image.memory(
              snapshot.data!,
              fit: fit,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _Blank(color: placeholderColor),
            );
          }
          return _Blank(color: placeholderColor);
        },
      );
}

class _Blank extends StatelessWidget {
  final Color color;
  const _Blank({required this.color});

  @override
  Widget build(BuildContext context) => ColoredBox(color: color);
}

class _PhotoViewer extends StatefulWidget {
  final int propertyId;
  final List<PropertyPhoto> photos;
  final int initialIndex;
  final Future<void> Function(PropertyPhoto) onRemove;

  const _PhotoViewer({
    required this.propertyId,
    required this.photos,
    required this.initialIndex,
    required this.onRemove,
  });

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final photos = widget.photos;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.propertiesPhotoDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              await widget.onRemove(photos[_index]);
              if (context.mounted) Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: widget.initialIndex),
        onPageChanged: (i) => setState(() => _index = i),
        itemCount: photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          maxScale: 4,
          child: Center(
            child: _PhotoImage(
              propertyId: widget.propertyId,
              photo: photos[i],
              fit: BoxFit.contain,
              placeholderColor: t.surfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
