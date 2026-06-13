
import "package:supabase/supabase.dart";

void main() async {
  final client = SupabaseClient(
    "https://zqihvfzxgrfsgbfziwly.supabase.co",
    "sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW"
  );

  try {
    print("Creating takaful@test.dz...");
    final res1 = await client.auth.admin.createUser(
      AdminUserAttributes(
        email: "takaful@test.dz",
        password: "test123",
        emailConfirm: true,
        userMetadata: {
          "company": "algeria_takaful",
          "role": "operator"
        }
      )
    );
    print("Takaful user created: " + res1.user!.id);
  } catch (e) {
    print("Error creating takaful: " + e.toString());
  }

  try {
    print("Creating itihad@test.dz...");
    final res2 = await client.auth.admin.createUser(
      AdminUserAttributes(
        email: "itihad@test.dz",
        password: "test123",
        emailConfirm: true,
        userMetadata: {
          "company": "algerie_ittihadd",
          "role": "operator"
        }
      )
    );
    print("Itihad user created: " + res2.user!.id);
  } catch (e) {
    print("Error creating itihad: " + e.toString());
  }
}
