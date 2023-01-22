variable "cluster_name"{
    default = "cley-eks"
}

variable "state_bucket"{
    default = "cley-eks-tfstate-bucket"
}

variable "state_key"{
    default = "cley-eks-networking.tfstate"
}

variable "state_region"{
    default = "eu-west-3"
}