import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}


class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> produtos = [
    {
      "nome": "Motor Elétrico",
      "descricao": "Alta eficiência para uso industrial",
      "preco": 1500.0
    },
    {
      "nome": "Inversor de Frequência",
      "descricao": "Controle de velocidade",
      "preco": 2300.0
    },
    {
      "nome": "Sensor Industrial",
      "descricao": "Alta precisão",
      "preco": 350.0
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catálogo Industrial"),
      ),
      body: Column(
        children: produtos.map((produto) {
          return Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info do produto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto["nome"],
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(produto["descricao"]),
                  ],
                ),

                // Botão detalhes
                ElevatedButton(
                  child: Text("Detalhes"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhePage(produto: produto),
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}


class DetalhePage extends StatefulWidget {
  final Map<String, dynamic> produto;

  DetalhePage({required this.produto});

  @override
  _DetalhePageState createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  int quantidade = 0;

  void incrementar() {
    setState(() {
      quantidade++;
    });
  }

  void decrementar() {
    if (quantidade > 0) {
      setState(() {
        quantidade--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  widget.produto["nome"],
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(height: 10),
                Text(widget.produto["descricao"]),
                SizedBox(height: 10),
                Text("R\$ ${widget.produto["preco"]}"),
              ],
            ),
          ),

          
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: decrementar,
                  child: Text("-"),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    quantidade.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: incrementar,
                  child: Text("+"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}