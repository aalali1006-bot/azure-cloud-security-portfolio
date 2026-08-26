variable "location" {
  description = "Azure-Region für alle Ressourcen, z. B. westeurope."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Kurzer Umgebungsname; nur Kleinbuchstaben und Ziffern."
  type        = string
  default     = "lab"

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.environment))
    error_message = "environment muss 2 bis 8 Kleinbuchstaben oder Ziffern enthalten."
  }
}

variable "project_name" {
  description = "Präfix für Ressourcen."
  type        = string
  default     = "cloudsecurity"

  validation {
    condition     = can(regex("^[a-z0-9]{3,15}$", var.project_name))
    error_message = "project_name muss 3 bis 15 Kleinbuchstaben oder Ziffern enthalten."
  }
}

variable "developer_group_object_id" {
  description = "Object ID der Entra-Testgruppe cs-lab-developers."
  type        = string
  nullable    = false
}

variable "reader_group_object_id" {
  description = "Object ID der Entra-Testgruppe cs-lab-readers."
  type        = string
  nullable    = false
}

variable "security_operator_group_object_id" {
  description = "Object ID der Entra-Testgruppe cs-lab-security-operators."
  type        = string
  nullable    = false
}
