import 'package:crud_supabase/login.dart';
import 'package:crud_supabase/signup.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gpggykixrfsbnqrioxkg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwZ2d5a2l4cmZzYm5xcmlveGtnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0MjYzMzEsImV4cCI6MjA1MDAwMjMzMX0.Tg82QTgcX2i8DSUZ9LiHrmoXxiwBkWLreh85KVo2img',
  );
  runApp(const MyApp());
}
final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpScreen()
    );
  }
}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //User signout
 Future<void> signOut() async {
   await supabase.auth.signOut();
   if(!mounted) return;
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
 }


 final noteStream = supabase.from('notes').stream(primaryKey: ['id']);
  //Create note
 Future<void> createNote(String note) async {
   await supabase.from('notes').insert({'body': note});

 }

  //Update note
 Future<void> updateNote(String noteId, String updatedNote) async {
   await supabase.from('notes').update({'body': updatedNote}).eq('id', noteId);
 }

  //Delete note
 Future<void> deleteNote(String noteId) async {
   await supabase.from('notes').delete().eq('id', noteId);
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Notes"),
        actions: [
          IconButton(onPressed: signOut, icon: Icon(Icons.logout_outlined),)
        ],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return SimpleDialog(
              title: Text("Add a note"),
              children: [
                TextFormField(
                  onFieldSubmitted: (value){
                    createNote(value);
                    if(mounted) Navigator.pop(context);
                  },
                )
              ],
            );
          });
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(stream: noteStream, builder: (context,snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data!;
        return ListView.builder(
          itemCount: notes.length,
            itemBuilder: (context,index){
              final note = notes[index];
              final noteId = note['id'].toString();
              return ListTile(
                title: Text(note['body']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: (){
                          showDialog(context: context, builder: (context){
                            return SimpleDialog(
                              title: Text("Edit a note"),
                              children: [
                                TextFormField(
                                  initialValue:note['body'],
                                  onFieldSubmitted: (value) async{
                                   await updateNote(noteId, value);
                                    if(mounted) Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                        }, 
                        icon: Icon(Icons.edit),
                    ),
                    IconButton(
                        onPressed: ()async{
                          bool deletedConfirmed = await showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text('Delete Note'),
                                  content: Text("Are you sure you want to delete this note?"),
                                  actions: [
                                    TextButton(onPressed: (){
                                      Navigator.pop(context,false);
                                    }, child: Text("Cancel")),
                                    TextButton(onPressed: (){
                                      Navigator.pop(context,true);
                                    }, child: Text("Delete")),
                                  ],
                                );
                              },);
                          if(deletedConfirmed){
                            await deleteNote(noteId);
                          }
                        },

                        icon: Icon(Icons.delete),
                    )
                  ],
                ),
              );
            },);
      }),
    );
  }
}

