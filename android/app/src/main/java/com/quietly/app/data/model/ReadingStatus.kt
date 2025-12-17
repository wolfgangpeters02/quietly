package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class ReadingStatus {
    @SerialName("want_to_read")
    WANT_TO_READ,

    @SerialName("reading")
    READING,

    @SerialName("completed")
    COMPLETED
}
