import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/features/library/bloc/library_bloc.dart';
import 'package:ginfit/app/features/library/ui/screens/generated_image_card.dart';
import 'package:ginfit/generated/l10n.dart';

class AllImagesScreen extends StatefulWidget {
  const AllImagesScreen({super.key});

  @override
  State<AllImagesScreen> createState() => _AllImagesScreenState();
}

class _AllImagesScreenState extends State<AllImagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).allImages),
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          final images = state.userGeneratedImages ?? [];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  final image = images[index];
                  return AspectRatio(
                    aspectRatio: 1,
                    child: GeneratedImageCard(image: image!),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
