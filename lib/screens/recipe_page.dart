import 'package:flutter/material.dart';
import 'package:recipe_app/utils/http_service.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final HttpService httpService = HttpService();
  TextEditingController _searchController = TextEditingController();
  final ScrollController controller = ScrollController();
  List<Recipe> recipeMaker = [];
  String search;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          centerTitle: true,
          title: Text(
            'Recipe Finder',
            style: TextStyle(
              color: Colors.purple[200],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Recipe',
              ),
              onSubmitted: (text) async {
                search = _searchController.text;
                recipeMaker = await httpService.getRecipes(search);
                setState(() {
                  controller.animateTo(0,
                      duration: Duration(microseconds: 500),
                      curve: Curves.easeInOut);
                  if (recipeMaker.isEmpty) {
                    print('No Recipes');
                  }
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: controller,
              itemCount: recipeMaker.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      print(recipeMaker[index].url);
                      _launchURL(recipeMaker[index].url);
                    },
                    child: Stack(
                      fit: StackFit.loose,
                      children: <Widget>[
                        Container(
                          height: 165.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://spoonacular.com/recipeImages/' +
                                      recipeMaker[index].id.toString() +
                                      '-636x393.jpg'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: limitText(recipeMaker[index].title),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[200],
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
        onPressed: () async {
          search = _searchController.text;
          recipeMaker = await httpService.getRecipes(search);
          setState(() {
            controller.animateTo(0,
                duration: Duration(microseconds: 500), curve: Curves.easeInOut);
            if (recipeMaker.isEmpty) {
              print('No Recipes');
            }
          });
        },
      ),
    );
  }

  String limitText(String text) {
    if (text.length > 20) {
      return text.substring(0, 1).toUpperCase() + text.substring(1, 20) + '...';
    }
    return text;
  }
}

_launchURL(String recipe) async {
  final url = recipe;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
