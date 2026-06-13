
import "package:supabase/supabase.dart";

void main() async {
  final client = SupabaseClient(
    "https://zqihvfzxgrfsgbfziwly.supabase.co",
    "sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW"
  );

  try {
    // 1. Fetch all users
    final page = await client.auth.admin.listUsers();
    final users = page; 

    for (var user in users) {
      if (user.email == "takaful@test.dz") {
        print("Found takaful user: " + user.id);
        await client.auth.admin.updateUserById(
          user.id,
          attributes: AdminUserAttributes(
            userMetadata: {
              ...(user.userMetadata ?? {}),
              "company": "algeria_takaful",
              "role": "operator",
            }
          )
        );
        print("Updated takaful@test.dz successfully!");
      } else if (user.email == "itihad@test.dz") {
        print("Found itihad user: " + user.id);
        await client.auth.admin.updateUserById(
          user.id,
          attributes: AdminUserAttributes(
            userMetadata: {
              ...(user.userMetadata ?? {}),
              "company": "algerie_ittihadd",
              "role": "operator",
            }
          )
        );
        print("Updated itihad@test.dz successfully!");
      }
    }
    
    print("Done!");
  } catch (e) {
    print("ERROR: " + e.toString());
  }
}
