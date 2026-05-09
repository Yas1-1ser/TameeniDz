enum PolicyStatus {
  pending,
  accepted, // UNLOCKS payment button
  paid,     // Client completed payment → receipt sent to operator
  rejected,
  modificationRequested,
}
