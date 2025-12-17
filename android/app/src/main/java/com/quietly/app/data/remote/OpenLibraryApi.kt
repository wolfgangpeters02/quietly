package com.quietly.app.data.remote

import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

data class OpenLibrarySearchResponse(
    val docs: List<OpenLibraryDoc> = emptyList(),
    val numFound: Int = 0
)

data class OpenLibraryDoc(
    val key: String? = null,
    val title: String? = null,
    val author_name: List<String>? = null,
    val isbn: List<String>? = null,
    val cover_i: Int? = null,
    val number_of_pages_median: Int? = null,
    val first_publish_year: Int? = null,
    val publisher: List<String>? = null
)

data class OpenLibraryWork(
    val title: String? = null,
    val description: Any? = null,
    val covers: List<Int>? = null
)

data class OpenLibraryISBN(
    val title: String? = null,
    val authors: List<OpenLibraryAuthor>? = null,
    val publishers: List<String>? = null,
    val number_of_pages: Int? = null,
    val publish_date: String? = null,
    val covers: List<Int>? = null,
    val works: List<OpenLibraryWorkRef>? = null
)

data class OpenLibraryAuthor(
    val key: String? = null,
    val name: String? = null
)

data class OpenLibraryWorkRef(
    val key: String? = null
)

interface OpenLibraryApi {
    @GET("search.json")
    suspend fun searchBooks(
        @Query("q") query: String,
        @Query("limit") limit: Int = 20,
        @Query("fields") fields: String = "key,title,author_name,isbn,cover_i,number_of_pages_median,first_publish_year,publisher"
    ): OpenLibrarySearchResponse

    @GET("works/{workId}.json")
    suspend fun getWork(
        @Path("workId") workId: String
    ): OpenLibraryWork

    @GET("isbn/{isbn}.json")
    suspend fun getByISBN(
        @Path("isbn") isbn: String
    ): OpenLibraryISBN

    companion object {
        const val BASE_URL = "https://openlibrary.org/"

        fun getCoverUrl(coverId: Int?, size: String = "M"): String? {
            return coverId?.let { "https://covers.openlibrary.org/b/id/$it-$size.jpg" }
        }

        fun getCoverUrlByISBN(isbn: String?, size: String = "M"): String? {
            return isbn?.let { "https://covers.openlibrary.org/b/isbn/$it-$size.jpg" }
        }
    }
}
