
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/theme/color.dart';

class StatusItem extends StatelessWidget {
  const StatusItem({
    super.key,
    required this.data,
    this.selected = false,
    this.onTap,
  });

  final Map<String, dynamic> data;
  final bool selected;
  final GestureTapCallback? onTap;

  @override

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        margin: const EdgeInsets.only(right: 10),
        width: MediaQuery.of(context).size.width * .4,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF5D6)
              : AppColor.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFFFFBC00),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: .5,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20,),
            (data["name"] == "Adoptados")?SvgPicture.asset(
              'assets/images/adoptado.svg',
              width: 30, // Ancho deseado
              height: 20, // Altura deseada
            ):SvgPicture.asset(
              'assets/images/disponible.svg',
              width: 30, // Ancho deseado
              height: 20, // Altura deseada
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Text(
                data["name"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Color(0xFFFF8D00) : AppColor.textColor,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
