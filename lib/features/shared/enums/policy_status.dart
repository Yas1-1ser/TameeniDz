enum PolicyStatus {
  pending,
  insurancePending, // For direct insurance requests
  accepted, // UNLOCKS payment button
  paid,     // Client completed payment → receipt sent to operator
  issued,   // Operator uploaded the final insurance document
  rejected,
  modificationRequested,
}
