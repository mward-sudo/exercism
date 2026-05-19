defmodule MediaType do
  @file_type_map %{
    elf: %{
      extension: "exe",
      media_type: "application/octet-stream",
      binary_signature: <<0x7F, 0x45, 0x4C, 0x46>>
    },
    bmp: %{
      extension: "bmp",
      media_type: "image/bmp",
      binary_signature: <<0x42, 0x4D>>
    },
    png: %{
      extension: "png",
      media_type: "image/png",
      binary_signature: <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
    },
    jpg: %{
      extension: "jpg",
      media_type: "image/jpg",
      binary_signature: <<0xFF, 0xD8, 0xFF>>
    },
    gif: %{
      extension: "gif",
      media_type: "image/gif",
      binary_signature: <<0x47, 0x49, 0x46>>
    }
  }

  @doc """
  Accepts a binary file and returns a matching media type. Returns nil if no match is found.
  """
  @spec detect_signature(bitstring()) :: nil | String.t()
  Enum.each(@file_type_map, fn {_key,
                                %{binary_signature: binary_signature, media_type: media_type}} ->
    def detect_signature(<<unquote(binary_signature), _::binary>>), do: unquote(media_type)
  end)

  def detect_signature(_), do: nil

  @doc """
  Accepts a file extension and returns a matching media type. Returns nil if no match is found.
  """
  @spec from_extension(String.t()) :: nil | String.t()
  Enum.each(@file_type_map, fn {_key, %{extension: extension, media_type: media_type}} ->
    def from_extension(unquote(extension)), do: unquote(media_type)
  end)

  def from_extension(_), do: nil
end

defmodule FileSniffer do
  @spec type_from_extension(String.t()) :: nil | String.t()
  def type_from_extension(extension) do
    MediaType.from_extension(extension)
  end

  @spec type_from_binary(bitstring()) :: nil | String.t()
  def type_from_binary(file_binary) do
    MediaType.detect_signature(file_binary)
  end

  @spec verify(file_binary :: bitstring(), extension :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def verify(file_binary, extension) do
    file_binary_type = type_from_binary(file_binary)
    file_extension_type = type_from_extension(extension)

    if file_binary_type == file_extension_type do
      {:ok, file_binary_type}
    else
      {:error, "Warning, file format and file extension do not match."}
    end
  end
end
