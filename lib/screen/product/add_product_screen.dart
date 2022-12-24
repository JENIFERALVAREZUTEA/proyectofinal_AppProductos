import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:app_productos/widget/border.dart';
import 'package:app_productos/widget/text_form_fileds/text_form_field_name.dart';
import 'package:provider/provider.dart';
import '../../../widget/navigator/navigator.dart';
import '../../provider/product.dart';
import '../../widget/alert_dialog/awesome_alert.dart';
import '../../widget/buttons/red_elevation_button.dart';
import '../../widget/responsive/responsive.dart';
import '../../widget/snack_bar/snack_bar_widget.dart';
import '../../widget/style_color.dart';
import '../../widget/text_form_fileds/text_form_filed_money.dart';
import 'widget/container_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    productProvider.deleteImage();
    return navigatorPopWidget(context);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    //
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'Añadir producto',
            style: Responsive.isMobile(context)
                ? titleWhiteMobileStyle
                : titleWhiteTabletStyle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              productProvider.deleteImage();
              navigatorPopWidget(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              children: [
                SizedBox(height: height * 0.02),
                FadeInLeft(
                  child: Consumer<ProductProvider>(
                    builder: (context, value, child) {
                      return value.showImage == null
                          ? ContainerWidget(
                              widget: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Añadir imagen',
                                    style: Responsive.isMobile(context)
                                        ? bodyBlackMobileStyle
                                        : bodyBlackTabletStyle,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(width * 0.02),
                                    child: Icon(
                                      Icons.image,
                                      size: width * 0.07,
                                    ),
                                  ),
                                ],
                              ),
                              callback: () {
                                productProvider.pickImage();
                              },
                            )
                          : ContainerWidget(
                              widget: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: borderWidget(context),
                                    child: FadeInImage(
                                      placeholder:
                                          const AssetImage('loading.gif'),
                                      image: FileImage(value.showImage!),
                                      width: width,
                                      height: height,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      placeholderFit: BoxFit.contain,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: primaryColor,
                                    ),
                                    onPressed: () {
                                      value.deleteImage();
                                    },
                                  ),
                                ],
                              ),
                              callback: () {
                                value.pickImage();
                              },
                            );
                    },
                  ),
                ),

                //product name
                FadeInLeft(
                  child: TextFormFieldNameWidget(
                    textEditingController: _nameController,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    maxLength: 500,
                    minLine: 1,
                    maxLine: 1,
                    labelText: 'Nombre del producto',
                    iconData: Icons.edit_outlined,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'El nombre del producto está vacío';
                      }
                      return null;
                    },
                  ),
                ),
                FadeInLeft(
                  child: TextFormFieldNameWidget(
                    textEditingController: _descriptionController,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    maxLength: 500,
                    minLine: 1,
                    maxLine: 1,
                    labelText: 'Descripcion',
                    iconData: Icons.edit_outlined,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'La descripcion del producto está vacío';
                      }
                      return null;
                    },
                  ),
                ),
                //product price
                FadeInLeft(
                  child: TextFormFieldMoneyWidget(
                    textEditingController: _priceController,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    maxLength: 50,
                    minLine: 1,
                    maxLine: 1,
                    labelText: 'precio',
                    iconData: Icons.money_rounded,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'El precio del producto está vacío.';
                      }
                      return null;
                    },
                  ),
                ),

                ElevationButtonWidget(
                  text: 'Guardar',
                  onPress: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (!_key.currentState!.validate()) {
                      alertDialogWarning(
                          context, 'Error', 'Problema con los valores ingresados');
                    } else {
                      if (productProvider.fileSize != null &&
                          double.parse(productProvider.fileSize.toString()) >=
                              double.parse('10.00')) {
                        alertDialogError(context, 'Error',
                            'El tamaño de la imagen seleccionada es grande');
                      } else {
                        if (productProvider.image != null &&
                            productProvider.fileType != 'png' &&
                            productProvider.fileType != 'jpg' &&
                            productProvider.fileType != 'jpeg') {
                          alertDialogError(context, 'Error',
                              'El formato de archivo seleccionado es incorrecto');
                        } else {
                          await productProvider.insertDatabase(
                            _nameController.text,
                            _descriptionController.text,
                            _priceController.text.replaceAll(',', ''),
                            productProvider.showImage == null
                                ? '0'
                                : productProvider.showImage!.path,
                          );
                          _priceController.clear();
                          _nameController.clear();
                          _descriptionController.clear();
                          productProvider.deleteImage();
                          snackBarSuccessWidget(context, 'Producto agregado');
                          navigatorPopWidget(context);
                        }
                      }
                    }
                  },
                  minSizeW: width * 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
