import 'package:flutter/material.dart';
import '../cart_store.dart'; import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar:AppBar(title:const Text('Keranjang',
      style:TextStyle(fontWeight:FontWeight.w800))),
    body:ValueListenableBuilder<List<Map<String,String>>>(
      valueListenable:CartStore.items,builder:(_,items,__){
        if(items.isEmpty)return const Center(child:Text('Keranjang Kosong'));
        return ListView(padding:const EdgeInsets.all(16),children:[
          ...items.asMap().entries.map((e){final p=e.value;return Card(
            child:ListTile(leading:Image.network(p['image']!,width:60,fit:BoxFit.cover),
              title:Text(p['name']!,style:const TextStyle(fontWeight:FontWeight.bold)),
              subtitle:Text(p['price']!),trailing:IconButton(
                onPressed:()=>CartStore.remove(e.key),
                icon:const Icon(Icons.delete_outline))));}),
          const SizedBox(height:18),const Text('Ringkasan Pesanan',
            style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
          const SizedBox(height:8),Text('Total item: ${items.length}'),
          const SizedBox(height:14),ElevatedButton(
            onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const CheckoutPage())),
            child:const Text('Lanjut Checkout')),
        ]);
      }));
}
