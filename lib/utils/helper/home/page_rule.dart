class PageRule {
  final List<String>? departments;
  final List<String>? managerDept;
  final List<String>? permissions;
  final List<String>? roles;
  final bool requireDept;

  const PageRule({
    this.departments,
    this.managerDept,
    this.permissions,
    this.roles,
    this.requireDept = false,
  });

  // Khai báo sẵn các rule dùng chung trong hệ thống
  static const admin = PageRule(roles: ["admin"]);
  static const sale = PageRule(departments: ["Sale"], permissions: ["sale"], requireDept: true);
  static const qc = PageRule(departments: ["QC"], requireDept: true);
  static const hr = PageRule(departments: ["HR"], permissions: ["HR"], requireDept: true);
  static const plan = PageRule(
    departments: ["Operation"],
    permissions: ["plan"],
    requireDept: true,
  );
  static const mixedAccountantSale = PageRule(
    departments: ["Accountant", "Sale"],
    permissions: ["accountant", "sale"],
    requireDept: true,
  );
}
