import "package:ginfit/core/constants/layout_constants.dart";
import "package:flutter/material.dart";

class GinlyHomeButton extends StatelessWidget {
  const GinlyHomeButton({
    required this.onPressed,
    required this.title,
    required this.icon,
    super.key,
  });

  final VoidCallback onPressed;
  final String title;
  final IconData icon;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              LayoutConstants.lowSize,
              LayoutConstants.midSize,
              LayoutConstants.lowSize,
              LayoutConstants.midSize),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      icon,
                      size: LayoutConstants.highSize,
                    ),
                  ),
                  SizedBox(
                    width: LayoutConstants.midSize,
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 32,
              )
            ],
          ),
        ),
      ),
    );
  }
}
