enum UserType {
  customer,
  promoter,
  scanner
}

enum LoginMethod {
  emailAndPassword,
  google,
  phoneAndOtp,
}

enum LoadingState {
  initial,
  skipping,
  verifying,
  uploading,
  loading,
  deleting,
  downloading,
  loaded,
  verified,
  deleted,
  aborted,
  uploaded,
  error,
}
