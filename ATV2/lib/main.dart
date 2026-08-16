import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> produtos = const [
    {
      "nome": "Motor Elétrico",
      "descricao": "Alta eficiência para uso industrial",
      "preco": 1500.0,
    },
    {
      "nome": "Inversor de Frequência",
      "descricao": "Controle de velocidade",
      "preco": 2300.0,
    },
    {
      "nome": "Sensor Industrial",
      "descricao": "Alta precisão",
      "preco": 350.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo Industrial"),
      ),
      body: Column(
        children: produtos.map((produto) {
          return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto["nome"],
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(produto["descricao"]),
                  ],
                ),
                ElevatedButton(
                  child: const Text("Detalhes"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhePage(produto: produto),
                      ),
                    );
                  },
                ),
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

  const DetalhePage({
    super.key,
    required this.produto,
  });

  @override
  State<DetalhePage> createState() => StateDetalhePage();
}

class StateDetalhePage extends State<DetalhePage> {
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
        title: const Text("Detalhes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  widget.produto["nome"],
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(widget.produto["descricao"]),
                const SizedBox(height: 10),
                Text("R\$ ${widget.produto["preco"]}"),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: decrementar,
                  child: const Text("-"),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    quantidade.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: incrementar,
                  child: const Text("+"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}