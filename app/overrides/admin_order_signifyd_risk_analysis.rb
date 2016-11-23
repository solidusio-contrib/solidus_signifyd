Deface::Override.new(
  virtual_path: "spree/admin/orders/_risk_analysis",
  name: "admin_order_signifyd_risk_analysis",
  insert_bottom: "[data-hook='order_details_adjustments']",
  partial: "spree/admin/orders/signifyd_score",
)

Deface::Override.new(
  virtual_path: "spree/admin/orders/_risk_analysis",
  name: "admin_order_signifyd_risk_analysis",
  insert_bottom: "#risk_analysis",
  partial: "spree/admin/orders/signifyd_link",
)
