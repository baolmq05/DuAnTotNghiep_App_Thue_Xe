import 'package:flutter/foundation.dart';
import '../models/policy_model.dart';
import 'base_service.dart';

class PolicyService extends BaseService {
  Future<List<PolicySection>> fetchPolicy() async {
    try {
      final response = await get('api/policies');
      if (response != null && response is List) {
        return response.map((json) => PolicySection.fromJson(json)).toList();
      }
      if (response != null && response is Map && response.containsKey('data')) {
        List<dynamic> dataList = response['data'];
        return dataList.map((json) => PolicySection.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('DRIVIO Policy: API fetch failed or not implemented ($e). Falling back to local data.');
    }

    return _getLocalFallbackPolicy();
  }

  List<PolicySection> _getLocalFallbackPolicy() {
    return [
      PolicySection(
        id: 1,
        title: '1. Trách nhiệm giao dịch',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'Mục đích lâu dài của DRIVIO là hướng đến việc xây dựng cộng đồng chia sẻ xe ô tô văn minh và uy tín tại Việt Nam. Vì thế, để đảm bảo các giao dịch thuê xe trong cộng đồng được diễn ra một cách thuận lợi và thành công tốt đẹp thì việc quy định trách nhiệm của các bên trong tuân thủ các chính sách của DRIVIO và các điều khoản cam kết là rất quan trọng.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'A. Trách nhiệm của chủ xe',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Giao xe và toàn bộ giấy tờ liên quan đến xe đúng thời gian và trong tình trạng an toàn, vệ sinh sạch sẽ nhằm đảm bảo chất lượng dịch vụ.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Các giấy tờ xe liên quan bao gồm: giấy đăng ký xe (bản photo công chứng), giấy kiểm định, giấy bảo hiểm xe (bản photo công chứng hoặc bản gốc).',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Chịu trách nhiệm pháp lý về nguồn gốc và quyền sở hữu của xe.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'B. Trách nhiệm khách thuê xe',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Kiểm tra kỹ xe trước khi nhận và trước khi hoàn trả xe. Kí xác nhận biên bản bàn giao về tình trạng xe khi nhận và khi hoàn trả.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Thanh toán đầy đủ tiền thuê xe cho Chủ xe khi nhận xe.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Tại thời điểm nhận xe khách hàng xuất trình đầy đủ các giấy tờ liên quan cho chủ xe: GPLX (chủ xe đối chiếu bản gốc với thông tin GPLX đã xác thực trên app DRIVIO & gửi lại), CCCD gắn chip (chủ xe đối chiếu bản gốc với thông tin cá nhân trên VNeID & gửi lại) Hoặc Hộ chiếu (passport) bản gốc giữ lại. Đặt cọc tài sản thế chấp tiền mặt (15 triệu hoặc theo thỏa thuận với chủ xe) hoặc xe máy có giá trị tương đương 15 triệu trước khi nhận xe (xe máy và cavet gốc).',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Đối với trường hợp chủ xe hỗ trợ chính sách miễn thế chấp: Khách hàng không cần để lại tài sản (xe máy hoặc 15 triệu tiền mặt) khi thuê xe của chủ xe. Trường hợp phát sinh các chi phí khác (nếu có) trong quá trình thuê xe, khách hàng vui lòng thanh toán trực tiếp cho chủ xe khi làm thủ tục trả xe.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Tuân thủ quy định và thời gian trả xe như 2 bên đã thỏa thuận.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Chịu trách nhiệm đền bù mọi thất thoát về phụ tùng, phụ kiện của xe, đền bù 100% theo giá phụ tùng chính hãng nếu phát hiện phụ tùng bị tráo đổi, chịu 100% chi phí sửa chữa xe nếu có xảy ra hỏng hóc tùy theo mức độ hư tổn của xe, chi phí các ngày xe nghỉ không chạy được do lỗi của khách thuê xe (giá được tính bằng giá thuê trong hợp đồng) và các khoản phí vệ sinh xe nếu có.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'C. Trách nhiệm và khuyến nghị của DRIVIO',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'DRIVIO khuyến nghị Chủ xe và Khách thuê xe cần thực hiện việc giao kết bằng văn bản "Hợp đồng cho thuê xe tự lái" cũng như kí kết "Biên bản bàn giao xe" nhằm đảm bảo quyền lợi của cả 2 bên trong trường hợp phát sinh tranh chấp.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Chủ xe có thể tham khảo sử dụng mẫu "Hợp đồng thuê xe tự lái" và "Biên bản bàn giao xe" của DRIVIO (vui lòng cung cấp email cho bộ phận CSKH của DRIVIO để nhận thông tin).',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Chủ xe và khách thuê xe tự chịu toàn bộ trách nhiệm dân sự và hình sự nếu có phát sinh tranh chấp giữa hai bên. DRIVIO chỉ đóng vai trò hỗ trợ hai bên dàn xếp các vấn đề một cách tốt đẹp nhất, tuân theo các điều khoản, chính sách và quy chế hoạt động cả hai bên đã cam kết với DRIVIO.',
          ),
        ],
      ),
      PolicySection(
        id: 2,
        title: '2. Sự cố ngoài ý muốn',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'Hiện tại, DRIVIO chỉ đóng vai trò là sàn giao dịch thương mại điện tử về cho thuê xe ô tô, là cầu nối giữa các chủ xe và khách hàng có nhu cầu thuê xe. Về cơ bản, mọi thủ tục và toàn bộ các vấn đề phát sinh liên quan đến giao dịch cho thuê xe giữa chủ xe và khách thuê sẽ do hai bên tự thỏa thuận, kí hợp đồng và chịu trách nhiệm với nhau.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Trong trường hợp có xảy ra sự cố ngoài ý muốn như xe bị cầm cố, thế chấp, bị bắt khi được dùng để vận chuyển ma túy, hàng quốc cấm hoặc gây ra tai nạn, DRIVIO sẽ cố gắng hỗ trợ tốt nhất các chủ xe trong khả năng của mình, giới hạn ở việc hướng dẫn chủ xe các thủ tục cần thiết để trình báo với cơ quan công an và các cơ quan có thẩm quyền, cung cấp các thông tin nếu có liên quan đến thành viên thuê xe hoặc các thông tin khác nếu có yêu cầu từ cơ quan chức năng, và tiến hành khóa vĩnh viễn tài khoản thành viên vi phạm.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Để bảo vệ tốt nhất tài sản của mình và giảm thiểu tối đa các rủi ro có thể xảy ra, các chủ xe cần ràng buộc chặt chẽ về mặt pháp lí bằng việc giao kết bằng văn bản "Hợp đồng cho thuê xe tự lái", "Biên bản bàn giao xe" (có thể tham khảo sử dụng mẫu hợp đồng và biên bản bàn giao do DRIVIO đề xuất hoặc có thể sử dụng mẫu riêng của nhà xe), xác minh đầy đủ thông tin và các giấy tờ cá nhân của khách thuê, giữ lại tài sản đặt cọc và các giấy tờ cần thiết (và tuyệt đối không giao cà vẹt xe bản chính cho khách thuê). Các chủ xe cũng cần trang bị cho xe thiết bị định vị GPS để có thể theo dõi và kiểm tra vị trí xe thường xuyên nhằm có các phương án xử lí kịp thời.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Thời gian tới, nhằm bảo vệ một cách toàn diện nhất quyền lợi của các chủ xe cũng như khách thuê, DRIVIO đang xúc tiến làm việc với các đối tác bảo hiểm để triển khai các sản phẩm bảo hiểm đối với dịch vụ thuê xe tự lái theo ngày, áp dụng cho tất cả các giao dịch cho thuê được thực hiện thông qua ứng dụng DRIVIO.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'DRIVIO hy vọng sẽ sớm hoàn thiện và triển khai gói giải pháp này trong thời gian sớm nhất.',
          ),
        ],
      ),
      PolicySection(
        id: 3,
        title: '3. Chính sách hủy chuyến',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'A. Dành cho khách thuê xe',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Trong trường hợp bất khả kháng bạn cần phải hủy chuyến, khách hàng có thể thao tác gửi "Yêu cầu hủy chuyến" trên web/app của DRIVIO. Việc hủy chuyến cần được thực hiện sớm nhất có thể, vì theo chính sách hủy chuyến khách hàng có thể mất phí giữ chỗ cho chủ xe.',
          ),
          PolicyContentElement(
            type: 'table',
            tableHeaders: ['Thời điểm hủy chuyến', 'Phí hủy chuyến'],
            tableRows: [
              ['Trong vòng 1h sau giữ chỗ', 'Miễn phí'],
              ['Trước chuyến đi > 7 ngày (Sau 1h giữ chỗ)', '10% giá trị chuyến đi'],
              ['Trong vòng 7 ngày trước chuyến đi (Sau 1h giữ chỗ)', '40% giá trị chuyến đi'],
            ],
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Trường hợp phát sinh phí hủy chuyến, DRIVIO sẽ trừ vào phí giữ chỗ của Quý khách hàng và sẽ thanh toán lại khoản tiền này cho Đối tác chủ xe (và ngược lại, trường hợp Đối tác chủ xe hủy chuyến phát sinh chi phí đền bù, DRIVIO sẽ hoàn trả lại 100% phí giữ chỗ và tiền phí đền bù cho Quý khách trong 1 - 3 ngày làm việc kể từ thời điểm ghi nhận thông tin số tài khoản ngân hàng).',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'B. Dành cho Chủ xe',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Nhằm gia tăng sự cam kết của chủ xe cũng như đảm bảo quyền lợi của khách thuê, trường hợp chủ xe hủy chuyến (vì lí do không giao đúng xe, không đảm bảo xe, không đúng giờ), nếu như không thỏa thuận được hoặc không có sự đồng ý từ phía khách thuê, thì chủ xe phải bồi thường phí hủy chuyến cho khách thuê theo chính sách hủy chuyến.',
          ),
          PolicyContentElement(
            type: 'table',
            tableHeaders: ['Thời điểm hủy chuyến', 'Phí hủy chuyến'],
            tableRows: [
              ['Trong vòng 1h sau giữ chỗ', 'Miễn phí'],
              ['Trước chuyến đi > 7 ngày (Sau 1h giữ chỗ)', '10% giá trị chuyến đi'],
              ['Trong vòng 7 ngày trước chuyến đi (Sau 1h giữ chỗ)', '40% giá trị chuyến đi'],
            ],
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Phí hủy chuyến sẽ được trừ vào tài khoản của chủ xe trên DRIVIO. Trong trường hợp số dư tài khoản của chủ xe nhỏ hơn số tiền phí hủy chuyến, phần chênh lệch sẽ được ghi âm vào tài khoản và sẽ cấn trừ vào thu nhập của chủ xe cho các chuyến xe tiếp theo.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Bên cạnh việc chịu phí, các chủ xe thực hiện hủy chuyến nhiều lần sẽ bị tạm khóa tài khoản thành viên trên ứng dụng DRIVIO.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Bộ phận CSKH của DRIVIO sẽ liên hệ với khách thuê xe thông báo về tình hình chuyến đi bị hủy, và tiến hành hoàn trả lại 100% tiền phí giữ chỗ và chi phí đền bù cho khách (nếu có).',
          ),
        ],
      ),
      PolicySection(
        id: 4,
        title: '4. Chính sách giá',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'A. Dành cho khách thuê xe',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Trên ứng dụng DRIVIO, mỗi dòng xe sẽ được cho thuê tại các mức giá khác nhau tùy thuộc vào sự quyết định của các chủ xe và được niêm yết công khai. Về cơ bản, cơ cấu giá của một chuyến đi được tính bao gồm các thành phần:',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Đơn giá thuê: Là giá thuê niêm yết bởi chủ xe mà bạn dễ dàng nhìn thấy trong phần thông tin xe. Giá thuê trên DRIVIO được tính theo đơn vị nhỏ nhất là ngày. Chủ xe có thể điều chỉnh giá thuê khác nhau cho từng ngày, chính vì vậy, chi phí thuê xe của bạn có thể tăng hoặc giảm tùy vào thời điểm bạn thuê xe. Thông thường, giá thuê sẽ cao hơn trong dịp cuối tuần và các ngày lễ, tết.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Chiết khấu: một số chủ xe có chính sách chiết khấu cho các chuyến xe kéo dài 1 tuần hoặc 1 tháng (mức chiết khấu bình quân từ 5-20% tùy vào quyết định của chủ xe). Vì thế, nếu bạn có nhu cầu thuê xe du lịch hay công tác dài ngày, hãy ưu tiên lựa chọn các chủ xe này để có được mức giá tốt hơn.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Chi phí vận chuyển: nếu bạn không có nhiều thời gian để đến trực tiếp địa điểm của chủ xe để nhận xe, bạn có thể lựa chọn các chủ xe có cung cấp thêm dịch vụ giao xe tận nơi. Chi phí giao nhận xe bình quân từ 5.000-15.000 VNĐ/km tùy vào quyết định của chủ xe được thể hiện tại phần thông tin xe và sẽ được cộng vào chi phí thuê xe của bạn.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Mã khuyến mãi: là mã giảm giá mà DRIVIO gửi tặng đến các thành viên của mình trong các đợt khuyến mãi, hoặc dành cho các thành viên thân thiết giao dịch thường xuyên trên ứng dụng DRIVIO. Mã khuyến mãi này sẽ được trừ trực tiếp vào chi phí thuê xe của bạn.',
          ),
          PolicyContentElement(
            type: 'formula',
            formulas: [
              {'label': 'Phí thuê xe', 'value': '= Đơn giá thuê ngày × Số ngày\n(Giá các ngày có thể thay đổi)'},
              {'label': 'Chiết khấu', 'value': '= % Chiết khấu × Phí thuê xe'},
              {'label': 'Phí vận chuyển', 'value': '= Đơn giá vận chuyển × Số km'},
              {'label': 'Khuyến mãi', 'value': '= % Khuyến mãi × (Phí thuê xe − Chiết khấu + Phí vận chuyển)'},
            ],
          ),
          PolicyContentElement(
            type: 'text',
            text: 'B. Dành cho Chủ xe',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Các chủ xe của DRIVIO được quyền thiết lập giá thuê xe hàng ngày cho tháng hiện hành và tối đa 3 tháng kế tiếp. Bạn có thể sử dụng giá đề xuất của DRIVIO hoặc có thể tùy chỉnh giá cho thuê theo mong muốn của bạn.',
          ),
          PolicyContentElement(
            type: 'bullet',
            text: 'Giá đề xuất của DRIVIO: được định vị thấp hơn 10% so với giá thuê xe bình quân trên thị trường. Mức giá này được tiến hành khảo sát hàng tháng bởi bộ phận phát triển thị trường của DRIVIO đối với từng dòng xe khác nhau.',
          ),
        ],
      ),
      PolicySection(
        id: 5,
        title: '5. Chính sách thanh toán',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'Sau khi nhận được sự đồng ý cho thuê xe từ phía chủ xe, bước tiếp theo, bạn cần phải thanh toán Phí giữ chỗ trước cho DRIVIO 40% Giá trị chuyến đi hoặc 100% Giá trị chuyến đi. Bạn có thể chọn lựa mức Phí giữ chỗ và hình thức thanh toán chuyển khoản qua ngân hàng trực tuyến hoặc Visa.',
          ),
          PolicyContentElement(
            type: 'text',
            text: 'Đối với hình thức thanh toán Phí giữ chỗ là 40% Giá trị chuyến đi, phần Phí còn lại 60% bạn sẽ thanh toán trực tiếp cho chủ xe ngay khi nhận được xe.',
          ),
        ],
      ),
      PolicySection(
        id: 6,
        title: '6. Chính sách thời gian giao nhận',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'Thời gian thuê xe mặc định trong hệ thống được thiết lập từ 9h tối đến 8h tối ngày kế tiếp. Tuy nhiên, khách hàng cũng có thể tùy chỉnh lựa chọn thời gian thuê xe theo nhu cầu của mình, trong vòng 24 giờ sẽ được tính 1 ngày.',
          ),
        ],
      ),
      PolicySection(
        id: 7,
        title: '7. Chính sách kết thúc sớm chuyến đi',
        elements: [
          PolicyContentElement(
            type: 'text',
            text: 'Trong trường hợp bạn muốn kết thúc sớm chuyến đi của mình khi vẫn chưa đến thời hạn trả xe, để có thể được hoàn lại tiền cho các ngày chưa sử dụng, bạn nên trao đổi trước với chủ xe và cần phải nhận được sự đồng ý từ phía chủ xe. Số tiền được hoàn lại sẽ do bạn và chủ xe tự thỏa thuận với nhau. Lưu ý rằng, bạn sẽ không được hoàn lại Phí giữ chỗ bạn đã thanh toán cho DRIVIO.',
          ),
        ],
      ),
    ];
  }
}
