import fitz  # PyMuPDF
import os
import glob


def main():
    directory = "permit-set/"
    pdf_files = glob.glob(directory + "*.pdf")

    for pdf_file_path in pdf_files:
        # Get the file name without extension
        file_name = os.path.splitext(os.path.basename(pdf_file_path))[0]
        # Extract the "arch" or "civil" part from the file name
        file_type = file_name.split('_')[1]
        output_directory = os.path.join(directory, 'extraction', file_name)

        # Create the output directory if it doesn't exist
        if not os.path.exists(output_directory):
            os.makedirs(output_directory)

        export_pdf_pages(pdf_file_path, output_directory, file_type)


def export_pdf_pages(pdf_path, output_dir, file_type):
    # Open the PDF file
    doc = fitz.open(pdf_path)

    print(f"Extracting... {pdf_path}")
    # Iterate through each page of the PDF
    for page_number in range(len(doc)):
        page = doc.load_page(page_number)

        # Save the page
        new_pdf = fitz.open()
        print(f"Exporting page {page_number}...")
        # https://github.com/pymupdf/PyMuPDF/issues/537#issuecomment-990233799
        new_pdf.insert_pdf(doc, from_page=page_number, to_page=page_number, annots=False)
        new_pdf.save(os.path.join(output_dir, f"{file_type}_page_{page_number + 1}.pdf"))
        # Define the resolutions (PPI) for each image type
        resolutions = {"UHD": 288, "HD": 144, "SD": 72, "Thumbnail": 36, "SmallThumbnail": 9}

        # Export each page in different resolutions
        for res_name, res_value in resolutions.items():
            zoom = res_value / 72  # Default PPI in PDF is 72
            mat = fitz.Matrix(zoom, zoom)
            pix = page.get_pixmap(matrix=mat)

            # Append the PDF file type to the beginning of the exported image file name
            output_file = os.path.join(output_dir, f"{file_type}_page_{page_number + 1}_{res_name}.jpg")
            pix.save(output_file)

    doc.close()
    print(f"Export completed. Images saved in {output_dir}")


if __name__ == '__main__':
    main()
